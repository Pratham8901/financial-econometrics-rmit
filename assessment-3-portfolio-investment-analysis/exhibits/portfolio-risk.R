wr_T <- 0.044
wr_C <- 1-wr_T
mur_P   <- wr_T*mu_tarmafore1 + wr_C*mu_carmafore1
sigmar_P <- sqrt((wr_T*sigma_tgarch1)^2 + (wr_C*sigma_cgarch1)^2 + 2*wr_T*wr_C*rho*sigma_tgarch1*sigma_cgarch1)
Pr_CVaR3 <- abs((mur_P + z_95*sigmar_P)/100 * initial_value)
