sink("diagnostics/lmer.txt")

library(lme4)
library(nortest)
library(RPostgreSQL)

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv, dbname="volleyball-m")

query <- dbSendQuery(con, "
select
r.game_id,
r.year,
r.field as field,
r.team_id as team,
r.team_div_id as o_div,
r.opponent_id as opponent,
r.opponent_div_id as d_div,
r.team_score as team_score,
r.opponent_score as opponent_score
from ncaa_pbp.results r

where
    r.year between 2012 and 2016
and r.team_div_id is not null
and r.opponent_div_id is not null
and not(r.team_score,r.opponent_score)=(0,0)

-- Exclude March,April
--and extract(month from r.game_date) not in (3,4)
;")

games <- fetch(query,n=-1)

dim(games)

attach(games)

pll <- list()

# Fixed parameters

year <- as.factor(year)
#contrasts(year)<-'contr.sum'

field <- as.factor(field)
#field <- relevel(field, ref = "neutral")

o_div <- as.factor(o_div)
d_div <- as.factor(d_div)

#game_length <- as.factor(game_length)

fp <- data.frame(year,field,d_div,o_div)
fpn <- names(fp)

# Random parameters

#game_id <- as.factor(game_id)
#contrasts(game_id) <- 'contr.sum'

offense <- as.factor(paste(year,"/",team,sep=""))
#contrasts(offense) <- 'contr.sum'

defense <- as.factor(paste(year,"/",opponent,sep=""))
#contrasts(defense) <- 'contr.sum'

rp <- data.frame(offense, defense)
rpn <- names(rp)

for (n in fpn) {
  df <- fp[[n]]
  level <- as.matrix(attributes(df)$levels)
  parameter <- rep(n,nrow(level))
  type <- rep("fixed",nrow(level))
  pll <- c(pll,list(data.frame(parameter,type,level)))
}

for (n in rpn) {
  df <- rp[[n]]
  level <- as.matrix(attributes(df)$levels)
  parameter <- rep(n,nrow(level))
  type <- rep("random",nrow(level))
  pll <- c(pll,list(data.frame(parameter,type,level)))
}

# Model parameters

parameter_levels <- as.data.frame(do.call("rbind",pll))
dbWriteTable(con,c("ncaa_pbp","_parameter_levels"),parameter_levels,row.names=TRUE)

g <- cbind(fp,rp)

dim(g)

model <- cbind(team_score,opponent_score) ~ year+field+o_div+d_div+(1|offense)+(1|defense)
fit <- glmer(model,
             data=g,
	     family=binomial(logit),
	     verbose=TRUE,
	     nAGQ=0,
	     control=glmerControl(optimizer = "nloptwrap"))

fit
summary(fit)

anova(fit)

# List of data frames

# Fixed factors

f <- fixef(fit)
fn <- names(f)

# Random factors

r <- ranef(fit)
rn <- names(r) 

results <- list()

for (n in fn) {

  df <- f[[n]]

  factor <- n
  level <- n
  type <- "fixed"
  estimate <- df

  results <- c(results,list(data.frame(factor,type,level,estimate)))

 }

for (n in rn) {

  df <- r[[n]]

  factor <- rep(n,nrow(df))
  type <- rep("random",nrow(df))
  level <- row.names(df)
  estimate <- df[,1]

  results <- c(results,list(data.frame(factor,type,level,estimate)))

 }

combined <- as.data.frame(do.call("rbind",results))

dbWriteTable(con,c("ncaa_pbp","_basic_factors"),as.data.frame(combined),row.names=TRUE)

f <- fitted(fit) 
r <- residuals(fit)

# Examine residuals

jpeg("diagnostics/fitted_vs_residuals.jpg")
plot(f,r)
jpeg("diagnostics/q-q_plot.jpg")
qqnorm(r,main="Q-Q plot for residuals")

quit("no")
