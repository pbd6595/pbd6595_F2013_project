//#include <R.h>
#include <iostream>
#include <fstream>
#include <sstream>
//#include <time>
#include "../../snap-core/Snap.h"


using namespace std;
string modeNames[] = {"rds", "rep", "dag", "not"};
string biasNames[] = {"inf", "non", "all"};
static   int graph_num = 1;

static TRnd my_random ((int) time(NULL));
class runArgs {
  TInt num_seeds;
  TInt seed_bias;
  TInt mode;
  TInt burn;
  TInt branch;
  char *  input_name;
  runArgs (TInt ns, TInt sb, TInt md, TInt bn, TInt br, char * in) :
    num_seeds (ns), seed_bias (sb), mode (md), burn (bn), branch (br), input_name (in) {}
};
class VisitedNode {
public:

  TInt id;
  VisitedNode * previous;
  TInt depth;

  VisitedNode () :  id (0), previous (NULL), depth (0) {}


  VisitedNode (TInt id, VisitedNode * previous = NULL) : id (id), 
						  previous (previous) {

    if (previous != NULL) depth = previous->depth + 1;
    else depth = 0;
  }


  TStr to_string () {

    if (previous == NULL) return id.GetStr() + ", NULL, " + depth.GetStr ();
    else return id.GetStr() + ", " +  previous->id.GetStr() + ", " 
	   + depth.GetStr ();   
  }
};

  THash <TInt, TInt> * choose (const TInt & population_size, const TInt & sample_size) {

    THash <TInt, TInt> * hits = new THash <TInt, TInt> ();
    //TRnd random ((int)time(NULL));
    //TRnd random (0);
    TInt min = TMath::Mn<TInt> (population_size, sample_size);

    for (int i = 0; i < min; i++) {

      TInt chosen = my_random.GetUniDevInt (population_size - i);
      if (hits->IsKey (chosen)) {

        hits->AddDat((*hits)(chosen), population_size - i - 1);
      }
      hits->AddDat(chosen, population_size - i - 1);
    }  
    return hits; 
  }

// Use nm -g statnet.so to find symbol names
TInt find (TInt choice, THash<TInt, TInt> choices, int lower, int upper) {
  if (lower == upper) return lower;
  TInt mid = (lower + upper) / 2;
  TInt val = choices[mid];
  if (choice < val) return find (choice, choices, lower, mid);
  else if (choice > val) return find (choice, choices, mid + 1, upper);
  else return mid;
}

double ave_path_length (PUNGraph p) {
  TVec<TInt> v;
  double tot_lengths = 0.0;
  for (TUNGraph::TNodeI n = p->BegNI(); n != p->EndNI(); n++) {
    v = v + n.GetId();
  }
  //  cerr << "vlen: " << v.Len() << endl;
  TBreathFS<PUNGraph> b(p);
  double tot_pairs = 0.0;
  while (v.Len () > 0) {
    TInt last = v[v.Len()-1];
    b.DoBfs (last, true, true);
    for (TVec<TInt>::TIter i = v.BegI(); (*i) != last; i++) {
      int length;
      length = b.GetHops (last, (*i));
      if (length == length) {
	tot_lengths += length;
	tot_pairs += 1;
      }
    }
    //    cerr << "tps: " << tot_pairs << ", last: " << last << ", beg: " << v[*(v.BegI())] << endl;
    v.Del(v.Len()-1);
  } 
  // cerr << "paths: " << tot_lengths << " " << tot_pairs << " " << (tot_lengths/tot_pairs) << endl;
  return tot_lengths / tot_pairs;
}
THash<TInt, TInt> * choose_seeds (const PUNGraph g, const int num, const int * infection_state, const int infect) {

  THash<TInt, TInt> choices; 
  THash<TInt, TUNGraph::TNode> nodes;
  THash<TInt, TInt> * output = new THash<TInt, TInt> ();
  TInt weight = 0;
  TInt num_total = 0;
  for (TUNGraph::TNodeI n = g->BegNI(); n != g->EndNI(); n++) {
    //cout << "nodeID: " << n.GetId() << ",\tStatus: " << infection_state[n.GetId () - 1] << endl;
    if (infection_state[n.GetId () - 1] != infect) {
      weight += n.GetDeg ();
      choices.AddDat (num_total, weight);
      nodes.AddDat (num_total, n.GetId());
      num_total++;
    }
  }
  //  TRnd random ((int) time(NULL));
  // TRnd random (0);
  TInt num_chosen = 0;
  while (num_chosen < num) {
    TInt choice = my_random.GetUniDevInt (weight);
    TUNGraph::TNode node_choice = nodes[find (choice, choices, 0,  num_total-1)];
    if (!output->IsKey(node_choice.GetId())) {
      num_chosen++;
      // cout << node_choice.GetId () << "\n";
      output->AddDat(node_choice.GetId (), 1);
    }
  }
  return output;
}

bool isChild (VisitedNode * current_node, TInt neighbor) {

  for (VisitedNode * node = current_node -> previous; node != NULL; node = node -> previous) 
    if (node -> id == neighbor) return true;
  return false;
}
      
PUNGraph get_PUNGraph (const int *m, const int nval, const int nodes) {

  PUNGraph g  = PUNGraph::New ();  

  for (int i = 1; i<= nodes; i++) {
    g->AddNode(i);
  }

  for (int i =0; i < nval; i++)  {
    g->AddEdge(m[i], m[nval + i]);
  }
  return g;
}

void get_graph_stats (const int *m, const int *n, const int *h) {
  const int nodes = *h;
  const int nval = (*n)/2;
  PUNGraph g = get_PUNGraph (m, nval, nodes);
  TSnap::GetClustCf(g, -1);
}

void sample (const int *m, const int *n, const int *h, const int *ns, const int *in, const int *infection_state, const int *mde, const int *bi, const int *br, double * result) {
  const int nodes = *h;
  const int nval = (*n)/2;
  int num_seeds = *ns;
  int infect_type = *in;
  int mode = *mde;
  int burnin = *bi;
  int branch = *br;

  PUNGraph g = get_PUNGraph (m, nval, nodes);

  THash<TInt, TInt> * visited = choose_seeds (g, num_seeds, infection_state, infect_type);
  TVec <VisitedNode *>  queue;
  TIntV qids;
  

  for (THash<TInt, TInt>::TIter n = visited->BegI(); n != visited->EndI(); n++) {
    queue = queue + new VisitedNode (n->Key);
    qids = qids + n->Key;
    //cerr << "enqueued " << n->Key << endl;
  }
  TInt counted = 0;
  TInt first_unprocessed = 0;
  TFlt infected_mass = 0.0;
  TFlt total_mass = 0.0;
  TFlt revisits = 0.0;
  TFlt trehits = 0.0;
  //cerr << "nodeId\tneigh\tnbh_size\tinfected?\tinfected_mass\ttotal_mass" << endl;
  while (counted < 500 && first_unprocessed < queue.Len()) {
    VisitedNode * current_node = queue [first_unprocessed];
    first_unprocessed++;
    TUNGraph::TNodeI NI = g->GetNI (current_node->id);
    TInt neighborhood_size = NI.GetDeg();
    //  cerr << counted << " " << current_node->id << endl;
    if (counted >= burnin) {
      if (infection_state[(current_node->id) - 1] == 1)
       infected_mass += 1.0/TFlt(neighborhood_size);
      total_mass += 1.0/TFlt(neighborhood_size);
    }
    //cerr << current_node->id << "\t" << neighborhood_size << "\t" << (1.0/TFlt(neighborhood_size)) 
    //	 << "\t" << infection_state[(current_node->id) - 1] << "\t" << infected_mass << "\t" << total_mass << endl;
    
    // build list of unvisited neighbors
    TVec<TInt> neighbors;
    for (int i = 0; i < neighborhood_size; i++) {
      TInt neighbor = NI.GetNbrNId(i);
      if (mode == 0 && visited->IsKey(neighbor)) continue;
      else if (mode == 2 && isChild (current_node, neighbor)) continue;
      else if (mode == 3 && current_node-> previous != NULL && current_node->previous->id == neighbor) continue;
      else neighbors = neighbors + neighbor;									
    }
    TInt num_legal_neighbors = neighbors.Len();
    TInt sample_size = TMath::Mn<TInt> (branch, num_legal_neighbors);
    THash <TInt, TInt> * choices = choose (num_legal_neighbors, sample_size);
    for (THash<TInt, TInt>::TIter n = choices->BegI(); n != choices->EndI(); n++) {
      if (queue.Len() >= 500) break;
      queue = queue + new VisitedNode (neighbors[n->Key], current_node);
      if (visited->IsKey(neighbors[n->Key])) revisits++;
      if (isChild(current_node, neighbors[n->Key])) trehits++;
      if (!visited->IsKey(neighbors[n->Key])) qids = qids + neighbors[n->Key];
      visited->AddDat(neighbors[n->Key], 1);
    }
    counted++;
  }
    
  // cout << (infected_mass / total_mass) << endl;
  delete (visited);
  result[0] = (infected_mass / total_mass);
  result[1] = revisits;
  result[2] = trehits;
  result[3] = counted;
  //PUNGraph p (&g);
  PUNGraph p = TSnap:: GetSubGraph (g, qids, false);
  TCnComV convec;
  result[4] = TSnap::GetClustCf(p, -1);
  TSnap::GetWccs(p, convec);
  result[5] = convec.Len();
  
  result[6] = ave_path_length (p);
}

void get_edges (ifstream & file, int * edges, int numedges) {
  for (int i = 0; i < numedges; i++) {
    file >> edges[i] >> edges[i+numedges];
  }
}

void get_nodes (ifstream & file, int * inf, int numnodes) {
  for (int j = 0; j < numnodes; j++) {
    file >> inf[j];
  }
}

void process_file (TInt num_seeds, TInt seed_bias, TInt mode, TInt burn, TInt branch, const char *  input_name, ofstream &  outfile) {
  ifstream file (input_name);

  string s;
  int numedges, numnodes;
  file >> s >> numedges;
  cerr << s  << "\t" << numedges << endl;

  while (numedges > 0) {
    int edges [2*numedges];
    get_edges (file, edges, numedges);
    file >> s >> numnodes;
    int inf[numnodes];
    get_nodes (file, inf, numnodes);
    double output[7];
    int total_deg = 2 * numedges;
    
    sample (edges, &total_deg, &numnodes, (int *) &num_seeds, (int *)&seed_bias, inf, (int *) &mode, (int *) &burn, (int *) &branch, output);
    outfile << graph_num << " " << output[0] << " " << output[1] << " " << output[2] << " " << output[3] << " " << output[4] << " " << output[5] << " " << output[6] << " " << numnodes << endl;
    graph_num ++;
    file >> s >> numedges;
  }
}

void run_short (TInt num_seeds, TInt seed_bias, TInt mode, TInt burn, TInt branch, const char *  input_name) {
  char line[1024];
  sprintf (line, "g-%s-s%d-%s-bu%d-%s-%d.out", input_name, (int) num_seeds, biasNames[seed_bias].c_str(), (int) burn, modeNames[mode].c_str(), (int) branch);
  ofstream outfile (line);
  outfile << "id est revisit intree samplesize netsize subclustercf subapl subccs" << endl;

  //  cerr << line << endl;
  sprintf( line, "%s.graph", input_name);
  process_file (num_seeds, seed_bias, mode, burn, branch, line, outfile);

}

void run_long (TInt num_seeds, TInt seed_bias,  TInt mode,TInt burn,
	       TInt branch, const char * input_name) {

  char line[1024];
  sprintf (line, "g-%s-s%d-%s-bu%d-%s-%d.out", input_name, (int) num_seeds, biasNames[seed_bias].c_str(), (int) burn, modeNames[mode].c_str(), (int) branch);
  ofstream outfile (line);
  cout << "outfile: " << line << endl;
  outfile << "id est revisit intree samplesize subclustercf subccs subapl netsize" << endl;

  int sizes [] = {1000, 715, 525};
  for (int i = 0; i < 3; i++) {
    sprintf( line, "g-%d-%s.graph", sizes[i], input_name);
    process_file (num_seeds, seed_bias, mode, burn, branch, line, outfile);
  }
}

void run_graph_long ( const char * input_name) {

  char line[1024];
  sprintf (line, "g-%s.out", input_name);
  ofstream outfile (line);
  cout << "outfile: " << line << endl;
  outfile << "id clustercf comps apl netsize" << endl;

  int sizes [] = {1000, 715, 525};
  for (int i = 0; i < 6; i++) {
    sprintf( line, "g-%d-%s.graph", sizes[i], input_name);
    ifstream file (line);
    cerr << "infile: " << line << endl;
    string s;
    int numedges, numnodes;
    file >> s >> numedges;
    cerr << s  << "\t" << numedges << endl;

    while (numedges > 0) {
      int edges [2*numedges];
      get_edges (file, edges, numedges);
      file >> s >> numnodes;
      int inf[numnodes];
      get_nodes (file, inf, numnodes);
    
      PUNGraph g = get_PUNGraph (edges, numedges, numnodes);
      TCnComV convec;
      TSnap::GetWccs(g, convec);
      
      outfile << graph_num << " " << TSnap::GetClustCf(g, -1) << " " << convec.Len() << " " << " " << ave_path_length (g) << " " << numnodes << endl;
      graph_num ++;
      file >> s >> numedges;
    }
  }
}


int main(int argc, char* argv[]) {
 
  TCon console;
  Env = TEnv(argc, argv, TNotify::StdNotify);
  //Env.PrepArgs(TStr(), 1, true);
  const TInt num_seeds = Env.GetIfArgPrefixInt 
    ("-seeds:", 6, "Number of seeds");
  const TInt seed_bias = Env.GetIfArgPrefixInt 
    ("-sbias:", 2, "Seed bias: 0=all infected, 1=all noninfected, 2=all");
  const TInt mode = Env.GetIfArgPrefixInt 
    ("-mode:", 0, "Sample mode: 0=RDS,1=with replacement, 2=DAG");
  const TInt burn = Env.GetIfArgPrefixFlt 
    ("-burn:", 0, "No. of nodes to drop for burn in.");
  const TInt branch = Env.GetIfArgPrefixInt 
    ("-branch:", 2,"Number of recruits each respondent gets");
  const TInt graphstats = Env.GetIfArgPrefixInt 
    ("-graphstats:", 0,"Just run graph stats?");
  const TStr input_name = Env.GetIfArgPrefixStr 
    ("-file:", "", "Input graph filename, without .graph extension");

  if (graphstats == 0) {
    run_long (num_seeds, seed_bias, mode, burn, branch, input_name());
  }
  else if (graphstats == 1) {
    run_short (num_seeds, seed_bias, mode, burn, branch, input_name());
  }
  else if (graphstats == 2) {
    run_graph_long (input_name());
  }
}
