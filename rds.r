library("statnet")
library("Rcpp")
gile.rds.trial <- function (g, num.seeds, where = 0) {
  degs=degree(g)
  degs[get.vertex.attribute(g,"infected") == where] <- 0
 
  seeds <- sample(get.vertex.attribute(g, "vertex.names"),num.seeds,prob=degs/sum(degs))
  queued <- vector(length=network.size(g))
  queued[seeds] <- TRUE
  queue <- vector(mode="numeric", length=network.size(g))
  queue[1:num.seeds] <- seeds
  head <- 1
  tail <- num.seeds
  infected.total <- 0
  total.mass <- 0
   
  while (head <= 500 & head <= tail) {
    current <- queue[head]
    head <- head + 1
    neighborhood <- get.neighborhood (g, current)
    if (get.vertex.attribute (g, "infected")[current] == TRUE) {
      infected.total <- infected.total + 1/length(neighborhood)
    }
    total.mass <- total.mass + 1/length(neighborhood)
    
    neighborhood <- neighborhood[!queued[neighborhood]]
    nsize <- length(neighborhood)
    if (nsize > 1) {
      nbrs <- sample (neighborhood, min (nsize, 2))
      for (neighbor in nbrs) {
        if (queued[neighbor] == FALSE & tail < 500) {
          queued[neighbor] <- TRUE
          tail <- tail + 1
          queue[tail] <- neighbor
        }
      }
    }
  }
  return (infected.total/total.mass)
}

get.graph.model <- function (graphsize, w) {
  # Set up sample model
  protonet <- network.initialize(graphsize,directed=FALSE)
  v <- vector(mode="integer",graphsize)
  v[1:(.2*graphsize)] <-1
  protonet %v% "infected" <- v
  constr <- formulate.constraints(graphsize, w)
  modl <- ergm (protonet~meandeg + nodematch("infected",diff=TRUE),target.stats=c(7,constr[3],constr[1]))
  return (modl)
}

 gile.rds.experiment <- function (samples, graphsize=1000, w) {
  
 
  modl <- get.graph.model (graphsize, w)

  return (lapply(vector(length=samples), function (x) simulate.ergm(modl)))
  # Iterate over all trials
  return (sapply(graphs, function (x) gile.rds.trial (modl=modl,num.seeds=seeds,where=where)))
}

giles.boxplots.2 <- function (graphs, ws) {
  graphs: c(1000,835,715,625,555,525)
   #ws: (c(1,1.1,1.4,1.8,3)
  args <- unlist(lapply(graphs, function(x) lapply(ws,function(y) c(x,y))),recursive=FALSE)
  return (lapply(lapply (args, function(x) gile.rds.experiment(1000, x[1], x[2])),
         function (y) lapply (y, function(g) gile.rds.trial (g=g,where=2,num.seeds=6))))
}

giles.boxplot.1 <- function () {
 graphs <- gile.rds.experiment (1000)

  d1 <- data.frame(est = unlist(lapply(graphs, function(g) gile.rds.trial (g=g,where=1,num.seeds=6))), Seeds=c("Uninfected"), Waves=c(6))
  print ("Experiment finished")
  d2 <- data.frame(est = unlist(lapply(graphs, function(g) gile.rds.trial(g=g,where=1,num.seeds=20))), Seeds=c("Uninfected"), Waves=c(4))
  print ("Experiment finished")
  d3 <- data.frame(est = unlist(lapply(graphs, function(g) gile.rds.trial(g=g,where=2,num.seeds=6))), Seeds=c("Random"), Waves=c(6))
  print ("Experiment finished")
  d4 <- data.frame(est = unlist(lapply(graphs, function(g) gile.rds.trial(g=g,where=2,num.seeds=20))), Seeds=c("Random"), Waves=c(4))
  print ("Experiment finished")
  d5 <- data.frame(est = unlist(lapply(graphs, function(g) gile.rds.trial(g=g,where=0,num.seeds=6))), Seeds=c("Infected"), Waves=c(6))
  print ("Experiment finished")
  d6 <- data.frame(est = unlist(lapply(graphs, function(g) gile.rds.trial(g=g,where=0,num.seeds=20))), Seeds=c("Infected"), Waves=c(4))
  print ("Experiment finished")
  return (rbind(d1,d2,d3,d4,d5,d6))
                  plot(g,vertex.col="infected")
}

formulate.constraints <- function (size, w) {
  m <- matrix (c(.16*size*size, -.2*size*(.2*size-1)*5/2, 0,  2, 2, 2,  1.6*size, (.8-.2*w)*size, -.4*size*w),3,3, byrow=TRUE)
  return (m)
  return (solve(m, c(0, 7*size, 0)))
}

gile.drawem <- function (d) {
  plot.new()
  layout(t(1:4))
  ylims <- c(.1, .3)
  par(oma=c(3, 4, 0, 0), mar=rep(1, 4), cex=1)
  
  boxplot(est~Waves,d[d$Seeds=="Uninfected",], ylim=ylims, axes=FALSE, boxwex=.7,col=c("white","yellow"), frame.plot=FALSE)
  mtext("Uninfected", 1, 1.5)
  abline(h=.2,lty=2,col="blue", xpd=TRUE)
  mtext( expression(paste("Waves", symbol("\256"))), 1,-.5, outer=TRUE, adj = -.1)
  mtext( expression(paste("Seeds", symbol("\256"))), 1,.5, outer=TRUE, adj= -.1)
  axis(2, las=0)
  axis(1, las=0, line = -.5, tick=FALSE, at=c(1,2), labels=c(4,6))
  mtext("Estimate of Proportion of Infected, Truth=0.20", 2, 3)
  
  boxplot(est~Waves,d[d$Seeds=="Random",], ylim=ylims, frame.plot=FALSE,boxwex=.7,col=c("white","yellow"), axes=FALSE)
  axis(1, las=0, line = -.5,tick=FALSE, at=c(1,2), labels=c(4,6))
  abline(h=.2,lty=2,col="blue", xpd=TRUE)
  mtext("Random", 1, 1.5)
  
  boxplot(est~Waves,d[d$Seeds=="Infected",], ylim=ylims, frame.plot=FALSE,boxwex=.7,col=c("white","yellow"), axes=FALSE)
  axis(1, las=0,line = -.5, tick=FALSE, at=c(1,2), labels=c(4,6))
  abline(h=.2,lty=2,col="blue", xpd=TRUE)
  mtext("Infected", 1, 1.5)
  
}

TestChars <- function(sign=1, font=1, ...) {
   if(font == 5) { sign <- 1; r <- c(32:126, 160:254)
   } else if (l10n_info()$MBCS) r <- 32:126 else r <- 32:255
   if (sign == -1) r <- c(32:126, 160:255)
   par(pty="s")
   plot(c(-1,16), c(-1,16), type="n", xlab="", ylab="",
        xaxs="i", yaxs="i")
   grid(17, 17, lty=1)
   for(i in r) try(points(i%%16, i%/%16, pch=sign*i, font=font,...))
}

make.graphb <- function (data, label) {
  ylims <- c(.1, .3)
  boxplot(est ~ netsize, data, ylim=ylims)
  mtext("label", 1, 1, adj=-.1, ce=.7)
  abline(h=.2,lty=2,col="blue", xpd=FALSE)

}
make.giles2b.tab <- function (base) {
 
  d1.1 <- read.delim(paste(base, '1.1.dat', sep = '.'), header=FALSE)
  colnames(d1.1) <- c('est', 'revisits', 'w', 'netsize')

  d1.4 <- read.delim(paste(base, '1.4.dat', sep = '.'), header=FALSE)
  colnames(d1.4) <- c('est', 'w', 'revisits', 'netsize')

  d1.8 <- read.delim(paste(base, '1.8.dat', sep = '.'), header=FALSE)
  colnames(d1.8) <- c('est', 'w', 'revisits', 'netsize')

  d3 <- read.delim(paste(base, '3.0.dat', sep = '.'), header=FALSE)
  colnames(d3) <- c('est', 'w', 'revisits', 'netsize')

  d1.1 <- d1.1[c(1:1000) > 500,]
  d1.4 <- d1.4[c(1:1000) > 500,]
  d1.8 <- d1.8[c(1:1000) > 500,]
  d3 <- d3[c(1:1000) > 500,]
  
  layout(matrix(c(1,2,3,4), 2,2))
  par(oma=c(3, 4, 0, 0), mar=rep(2, 4), cex=.7)

  ylims <- c(.1, .3)
  boxplot(est ~ netsize, d1.1, ylim=ylims)
  mtext("w = 1.1", 1, 1, adj=-.1, ce=.7)
  abline(h=.2,lty=2,col="blue", xpd=FALSE)

  boxplot(est ~ netsize, d1.4, ylim=ylims)
  mtext("w = 1.4", 1, 1, adj=-.1, ce=.7)
  abline(h=.2,lty=2,col="blue", xpd=FALSE)

  boxplot(est ~ netsize, d1.8, ylim=ylims)
  mtext("w = 1.8", 1, 1, adj=-.1, ce=.7)
  abline(h=.2,lty=2,col="blue", xpd=FALSE)

  boxplot(est ~ netsize, d3, ylim=ylims)
  mtext("w = 3", 1, 1, adj=-.1, ce=.7)
  abline(h=.2,lty=2,col="blue", xpd=FALSE)
 
}

make.giles2.tab <- function (base) {
 
  d1.1 <- read.delim(paste(base, '1.1.dat', sep = '.'), header=FALSE)
  colnames(d1.1) <- c('est', 'w', 'netsize')

  d1.4 <- read.delim(paste(base, '1.4.dat', sep = '.'), header=FALSE)
  colnames(d1.4) <- c('est', 'w', 'netsize')

  d1.8 <- read.delim(paste(base, '1.8.dat', sep = '.'), header=FALSE)
  colnames(d1.8) <- c('est', 'w', 'netsize')

  d3 <- read.delim(paste(base, '3.0.dat', sep = '.'), header=FALSE)
  colnames(d3) <- c('est', 'w', 'netsize')

  d1.1 <- d1.1[c(1:1000) > 500,]
  d1.4 <- d1.4[c(1:1000) > 500,]
  d1.8 <- d1.8[c(1:1000) > 500,]
  d3 <- d3[c(1:1000) > 500,]

  layout(matrix(c(1,2,3,4), 2,2))
  par(oma=c(3, 4, 0, 0), mar=rep(2, 4), cex=.7)

  ylims <- c(.1, .3)
  boxplot(est ~ netsize, d1.1, ylim=ylims)
  mtext("w = 1.1", 1, 1, adj=-.1, ce=.7)
  abline(h=.2,lty=2,col="blue", xpd=FALSE)

  boxplot(est ~ netsize, d1.4, ylim=ylims)
  mtext("w = 1.4", 1, 1, adj=-.1, ce=.7)
  abline(h=.2,lty=2,col="blue", xpd=FALSE)

  boxplot(est ~ netsize, d1.8, ylim=ylims)
  mtext("w = 1.8", 1, 1, adj=-.1, ce=.7)
  abline(h=.2,lty=2,col="blue", xpd=FALSE)

  boxplot(est ~ netsize, d3, ylim=ylims)
  mtext("w = 3", 1, 1, adj=-.1, ce=.7)
  abline(h=.2,lty=2,col="blue", xpd=FALSE)
 
}

sim_it <- function (seeds = 6, inf.exclude = 2, mode = 0, burnin = 0, spread=2, name = 'noname') {
#  dyn.load("rdssim.so")
  sourceCpp("rdssim.cpp")
  plot.new()
  pdf(file = paste(name, "pdf", sep="."))
  layout(matrix(c(1,2,3,4), 2,2))
  par(oma=c(3, 4, 0, 0), mar=rep(2, 4), cex=.7)

  run.models (seeds, inf.exclude, 1.1, mode, burnin, spread, name)
  run.models (seeds, inf.exclude, 1.4, mode, burnin, spread, name)
  run.models (seeds, inf.exclude, 1.8, mode, burnin, spread, name)
  run.models (seeds, inf.exclude, 3.0, mode, burnin, spread, name)
  dev.off()
}

run.models <- function (seeds, inf.exclude, w, mode, burnin, spread, name) {
  d <- rbind (run.model(1000, seeds, inf.exclude, w, mode, burnin, spread),
              run.model (835, seeds, inf.exclude, w, mode, burnin, spread),
              run.model (715, seeds, inf.exclude, w, mode, burnin, spread),
              run.model (625, seeds, inf.exclude, w, mode, burnin, spread),
              run.model (555, seeds, inf.exclude, w, mode, burnin, spread))
  save(d, file=paste(name, format(w,digits=2), "Rdata", sep="."))
  boxplot(est ~ netsize, d, ylim=c(.1,.3))
  mtext(paste ("w =", format(w,digits=2)), 1, 1, adj=-.1, ce=.7)
  abline(h=.2,lty=2,col="blue", xpd=FALSE)

}
read.and.draw <- function (file, l, name = "", outer=TRUE) {
  tab <- read.table (file, header = TRUE, sep=" ")
  boxplot(est ~ netsize, tab[tab$netsize==525|tab$netsize==715|tab$netsize==1000,], ylim=c(.1,.3))
  if(outer == TRUE) {
    mtext(paste ("w =", format(l,digits=2)), 2, 2) #, adj=-.1, ce=.7)
  }
  mtext(name,3,0)
  abline(h=.2,lty=2,col="blue", xpd=FALSE)
}
draw.four <- function (file1, file2, file3, file4, l1, l2, l3, l4) {
  plot.new()
  pdf(file = paste(file1, "pdf", sep="."))
  layout(matrix(c(1,2,3,4), 2,2))
  par(oma=c(3, 4, 0, 0), mar=rep(2, 4), cex=.7)
  read.and.draw (file1, l1)
  read.and.draw (file2, l2)
  read.and.draw (file3, l3)
  read.and.draw (file4, l4)
  dev.off()
}
draw.performance.graphs <- function () {
  draw.twelve('s6-all-bu0')
  draw.twelve('s6-inf-bu0')
  draw.twelve('s6-non-bu0')
  draw.twelve('s6-inf-bu100')
  draw.twelve('s6-non-bu100')
}

draw.top.performance.graphs <- function () {
  draw.fifteen('s6-all-bu0')
  draw.fifteen('s6-inf-bu0')
  draw.fifteen('s6-non-bu0')
  draw.fifteen('s6-inf-bu100')
  draw.fifteen('s6-non-bu100')
}

draw.twelve <- function (file) {
  plot.new()
  pdf(file = paste(file, "pdf", sep="."), width=7, height=3)
  layout(matrix(c(1,2,3,4,5,6,7,8), 2,4))
  par(oma=c(3, 4, 0, 0), mar=rep(2, 4), cex=.7)
  draw.three (paste (file, "rds-2.join", sep="-"), "RDS", TRUE)
  draw.three (paste (file, "dag-2.join", sep="-"), "DAG")
  draw.three (paste (file, "rep-2.join", sep="-"), "REP")
  draw.three (paste (file, "rep-1.join", sep="-"), "MCMC")
  dev.off ()
}
draw.fifteen <- function (file) {
  plot.new()
  pdf(file = paste(file, "pdf", sep="."), width=7, height=3)
  layout(matrix(c(1,2,3,4,5,6,7,8,9,10), 2,5))
  par(oma=c(3, 4, 0, 0), mar=rep(2, 4), cex=.7)
  draw.three (paste (file, "rds-2.join", sep="-"), "RDS", TRUE)
  draw.three (paste (file, "dag-2.join", sep="-"), "DAG")
  draw.three (paste (file, "not-2.join", sep="-"), "NOT")
  draw.three (paste (file, "rep-2.join", sep="-"), "REP")
  draw.three (paste (file, "rep-1.join", sep="-"), "MCMC")
  dev.off ()
}

draw.three <- function (file, name, outer=FALSE) {

   read.and.draw (paste ("g--1.1", file, sep="-"), 1.1, name,outer)
  read.and.draw (paste ("g--1.8", file, sep="-"), 1.8,"",outer)
   read.and.draw (paste ("g--3", file, sep="-"), 3.0,"",outer)
}

get.tests <- function (net.size, w, name) {
	modl <- get.graph.model (net.size, w)
	f <- file (paste(name, "dat", sep="."), open="w")
	m <- lapply(c(1:1000), function (x) simulate(modl))
	lapply(m, function (x) writeit(x,f,net.size))
	writeLines (text= "size 0", con = f)
	close(f)
	save (m, file=paste(name, "Rdata", sep="."))
}

writeit <- function (x, f, size) {
	writeLines (text= paste("size", format(size), sep=" "), con = f)
	write.table(as.matrix.network(x, matrix.type="edgelist"), sep = " ", file =f, row.names=FALSE, col.names=FALSE)
}

run.model <- function   (net.size, seeds, inf.exclude, w, mode, burnin, spread) {
  modl <- get.graph.model (net.size, w)
  d <- unlist (lapply(c(1:1000), function (x) get_sim (modl, seeds, inf.exclude, mode, burnin, spread)))
  d <- matrix (d, ncol=4, byrow=TRUE)
  d <- cbind (d, net.size)
  colnames(d) <- c("est", "revisit", "intree", "samplesize", "netsize")
  return (d)
}
get_sim <- function (modl, seeds = 6, inf.exclude = 2, mode, burnin, spread) {
  g <- simulate(modl)
  m <- as.matrix(g,matrix.type="edgelist")
  out <- .C("_Z6samplePKiS0_S0_S0_S0_S0_S0_S0_S0_Pd", as.integer(m), as.integer(length(as.integer(m))), as.integer(network.size(g)), 
	as.integer(seeds), as.integer(inf.exclude), as.integer(get.vertex.attribute(g,"infected")), as.integer(mode), 
	as.integer(burnin), as.integer(spread), result=double(4))
  return (matrix(out$result, ncol=4))
}


run_sims <-function () {
  sim_it(6,2,1,0,"g2-replace");
  sim_it(6,2,2,0,"g2-dag");
  sim_it(6,1,1,0,"g2-replace-non");
  sim_it(6,1,2,0,"g2-dag-non");
  sim_it(6,0,1,0,"g2-replace-inf");
  sim_it(6,0,2,0,"g2-dag-inf");
  sim_it(6,1,0,0,"g2-rds-non");
  sim_it(6,0,0,0,"g2-rds-inf");
  
}


test_rcpp <- function(){
sourceCpp("rdssim.cpp")
}
#running models-edited by pbd6595
#sims<-run_sims()

test_rcpp()
