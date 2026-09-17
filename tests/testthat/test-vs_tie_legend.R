make_vs_tie_legend_plot <- function() {
  methods <- c('p-PP','Separate','RMP','Pooling','NPP','EBPP','Conditional PP','Com. PP')
  p <- ggplot()
  for (method in methods) {
   n <- switch(method, RMP=9, 'Conditional PP'=3, 'Com. PP'=3, 1)
   params <- if (method %in% c('Pooling','Separate','EBPP')) list(expression('')) else lapply(seq_len(n),function(i) bquote(w == .(i/10)))
   d <- data.frame(x=seq_len(n)/20,y=seq_len(n)/10,k=factor(seq_len(n)))
   p <- p + geom_point(data=d,aes(x,y,colour=k),shape=match(method,methods)) + scale_colour_discrete(name=if(n==1) NULL else method,labels=vs_tie_key_labels(method,params),guide=guide_legend(ncol=min(n,3),byrow=TRUE)) + new_scale_color()
  }
  p <- p + theme_bw(base_size=12) + theme(legend.key.size=grid::unit(.1,'cm'),legend.margin=margin(2,2,2,2))
  list(plot = p, methods = methods)
}

test_that("legend placement follows method names, including inline math labels", {
  fixture <- make_vs_tie_legend_plot()
  legend <- vs_tie_legend_grid(fixture$plot, rev(fixture$methods))
  expected <- PAPER_VS_TIE_LEGEND_LAYOUT
  for (i in seq_along(legend$grobs)) {
    texts <- vs_tie_legend_text(legend$grobs[[i]])
    cell <- legend$layout[i, ]
    method <- expected[cell$t, cell$l]
    expect_true(any(texts == method | startsWith(texts, paste0('"', method, '" ~'))))
    expect_true(all(expected[cell$t:cell$b, cell$l:cell$r] == method))
  }
  expect_length(legend$grobs, 8)
})

test_that("spanning legends fit without counting their size repeatedly", {
  fixture <- make_vs_tie_legend_plot()
  legend <- vs_tie_legend_grid(fixture$plot, fixture$methods)
  for (i in seq_along(legend$grobs)) {
    cell <- legend$layout[i, ]
    g <- legend$grobs[[i]]$children[[1]]
    expect_gte(sum(as.numeric(legend$widths[cell$l:cell$r])) + 1e-8,
      grid::convertWidth(grid::grobWidth(g), "in", valueOnly = TRUE))
    expect_gte(sum(as.numeric(legend$heights[cell$t:cell$b])) + 1e-8,
      grid::convertHeight(grid::grobHeight(g), "in", valueOnly = TRUE))
  }
  composed <- vs_tie_compose(fixture$plot, fixture$methods, 1, 2)
  expect_gte(composed$width, sum(as.numeric(legend$widths)))
})

test_that("missing methods leave no empty rows and extra methods are retained", {
  p <- ggplot2::ggplot(data.frame(x = 1, k = "a"), ggplot2::aes(x, x, colour = k)) +
    ggplot2::geom_point() + ggplot2::scale_colour_discrete(name = "Extra")
  legend <- vs_tie_legend_grid(p, c("Pooling", "Extra"))
  expect_length(legend$grobs, 1)
  expect_length(legend$heights, 1)
  expect_null(vs_tie_legend_grid(p + ggplot2::guides(colour = "none"), "Extra"))
})
