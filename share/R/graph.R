library('ggplot2')
library('plyr')
library('reshape')

rbbt.graph.incidence.layer.sort_by_mutations <- function(plot){
    d = plot$data;

    d$Gene = reorder(d$Gene, d$Mutated, sum);
    num.elems = length(levels(d$Gene));

    sample.best.gene.pos.df = ddply(d, "Sample", function(x){ 1/sum(2^(num.elems - match(subset(x, Mutated==TRUE)$Gene, rev(levels(d$Gene)))))})

    d$sample.best.gene.pos = NULL
    names(sample.best.gene.pos.df) <- c("Sample", "sample.best.gene.pos");

    d = merge(d, sample.best.gene.pos.df, all.x=TRUE)

    d$Sample = reorder(d$Sample, d$sample.best.gene.pos)

    plot$data = d;

    return(plot);
}

rbbt.graph.incidence.layer <- function(incidence.matrix, sample.info = NULL){
    incidence.matrix[,] = as.logical(as.matrix(incidence.matrix))
    gene.mutation.counts = apply(incidence.matrix, 2, function(x){sum(x==TRUE)})

    cutoff = round(dim(incidence.matrix)[1] * 0.05)
    cutoff = max(c(cutoff,2))

    recurrent.genes = names(gene.mutation.counts[gene.mutation.counts >= cutoff])

    d.recurrent = incidence.matrix[, recurrent.genes]
    d.recurrent$Sample = rownames(d.recurrent)

    d.recurrent.m = melt(d.recurrent, "Sample")

    names(d.recurrent.m) <- c("Sample", "Gene", "Mutated")

    if (is.null(sample.info)){
        d = d.recurrent.m
    }else{
        d = merge(d.recurrent.m, sample.info, all.x=TRUE)
    }

    layer.mutations = geom_tile(data=d,aes(x=Sample, y=Gene, alpha=Mutated))

    rbbt.graph.incidence.layer.sort_by_mutations(layer.mutations);

    return(layer.mutations);
}

rbbt.graph.incidence <- function(incidence.matrix, filename){
    layer = rbbt.graph.incidence.layer(incidence.matrix);

    plot  = ggplot() + layer
    #plot  = plot + theme(axis.text.x=element_text(angle=90), panel.background = element_rect(fill='white', colour='steelblue'))
    plot  = plot + theme(axis.text.x=theme_blank(), panel.background = element_rect(fill='white', colour='steelblue'))

    ggsave(plot, filename=filename); #, height=5, width=5);
}
