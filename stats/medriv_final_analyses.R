library(car) # companion to applied regression
library(MASS)
library(lme4) #Linear mixed effect model
library(lsmeans) # Least squares means 
library(reshape)
library(reshape2)
library(ggpubr)
library(tidyverse)
library(cluster)
library(ordinal)
library(gridExtra)
library(grid)
library(cowplot)
library(tiff)

multi_spread <- function(df, key, value) {
  # quote key
  keyq <- rlang::enquo(key)
  # break value vector into quotes
  valueq <- rlang::enquo(value)
  s <- rlang::quos(!!valueq)
  df %>% gather(variable, value, !!!s) %>%
    unite(temp, !!keyq, variable) %>%
    spread(temp, value)
}

### read the data file and initialise the factors
medriv_data = read.csv(
  '~/OneDrive/Projects/Experiments/Meditation_Rivalry/Data/wpli_blockwise_gamma.csv',
  header = TRUE, sep = ',')

medriv_data <- medriv_data %>%
  mutate_if(is.integer, as.factor) %>%
  mutate(block = recode_factor(block, "1" = "BR1", "2" = "BR2", "3" = "BR3"),
         group = recode_factor(group, "1" = "Meditators", "2" = "Controls")) #%>%


medriv_data$mixmedian[medriv_data$mixmedian==0] = 0.2; ## GLM does not like 0 values of duration
symnum.args <- list(cutpoints = c(0,0.01, 0.05, 0.1, .5, 1), 
                    symbols = c("", "", "", "", ""))

stat_summ_size <- 1.25
alphaval <- .65
font_size <- 12


###########################################
### plot dominance durations without removing outliers
md.plot <- filter(medriv_data) %>% 
  group_by(group, subj, block) %>%
  summarise(dommedian = mean(dommedian))

# gp.dom.nol <- ggplot(md.plot, aes(x = block, y = dommedian, colour = block)) +
#   xlab("Block") + ylab("Dominance durations (s)") +
#   facet_wrap(~group) +
#   theme_pubclean() +
#   geom_boxplot(outlier.alpha = 0) +
#   # stat_summary(fun.data = mean_cl_boot, size = stat_summ_size) +
#   coord_cartesian(ylim = c(0, 15)) +
#   geom_jitter(position = position_jitter(width = 0.08),
#               alpha = alphaval) +
#   theme(legend.position = "none", 
#         text = element_text(size=font_size), 
#         plot.caption = element_text(size = font_size),
#         plot.tag = element_text(size = font_size, face = "bold"))


gp.dom.nol <- ggplot(md.plot, aes(x = block, y = dommedian, colour = block)) +
  xlab("Block") + ylab("Dominance durations (s)") +
  facet_wrap(~group) +
  theme_pubclean() +
  geom_boxplot(outlier.alpha = 0) +
  # stat_summary(fun.data = mean_cl_boot, size = stat_summ_size) +
  coord_cartesian(ylim = c(0, 15)) +
  geom_jitter(position = position_jitter(width = 0.08),
              alpha = alphaval) +
  # scale_color_grey() +
  theme(legend.position = "none", 
        text = element_text(size=font_size), 
        plot.caption = element_text(size = font_size),
        plot.tag = element_text(size = font_size, face = "bold"))


###########################################
### plot dominance durations without removing outliers
md.plot <- filter(medriv_data, subjcode!=4148) %>% 
  group_by(group, subj, block) %>%
  summarise(dommedian = mean(dommedian))
my_comparisons <- list()
# gp.dom <- ggplot(md.plot, aes(x = block, y = dommedian, colour = block)) + 
#   xlab("Block") + ylab("Dominance durations (s)") +
#   facet_wrap(~group) +
#   theme_pubclean() +
#   geom_boxplot(outlier.alpha = 0) +
#   coord_cartesian(ylim = c(1, 10)) + 
#   geom_jitter(position = position_jitter(width = 0.08),
#               alpha = alphaval) +
#   theme(legend.position = "none", 
#         text = element_text(size=font_size), 
#         plot.caption = element_text(size = font_size),
#         plot.tag = element_text(size = font_size, face = "bold"))

gp.dom <- ggplot(md.plot, aes(x = block, y = dommedian)) + 
  xlab("Block") + ylab("Dominance durations (s)") +
  facet_wrap(~group) +
  theme_pubclean() +
  geom_boxplot(outlier.alpha = 0) +
  coord_cartesian(ylim = c(1, 10)) +
  geom_jitter(position = position_jitter(width = 0.08),
              alpha = alphaval) +
  theme(legend.position = "none", 
        text = element_text(size=font_size), 
        plot.caption = element_text(size = font_size),
        plot.tag = element_text(size = font_size, face = "bold")) + 
  scale_color_grey()
gp.dom

##### stats on dominance durations
md.aov <- lmer(dommedian ~ group*block + (1|subj), 
                    md.plot)
plot(md.aov)

md.aov <- glmer(dommedian ~ group*block + (1|subj), 
                     md.plot, family = gaussian("log"))
plot(md.aov)

md.aov <- glmer(dommedian ~ group*block + (1|subj), 
                     md.plot, family = Gamma("identity"))
plot(md.aov)

md.aov <- glmer(dommedian ~ group*block + (1|subj), 
                     md.plot, family = gaussian("inverse"))
plot(md.aov)

md.aov <- glmer(dommedian ~ group*block + (1|subj), 
                     md.plot, family = Gamma("log"))
plot(md.aov)

md.aov <- glmer(dommedian ~ group*block + (1|subj), 
                     md.plot, family = Gamma("inverse"))
plot(md.aov)
Anova(md.aov)


###########################################
### plot mix durations with outliers
md.plot <- filter(medriv_data) %>%
  group_by(group, subj, block) %>%
  summarise(mixmedian = mean(mixmedian))

gp.mix.nol <- ggplot(md.plot, aes(x = block, y = mixmedian, colour = block)) +
  xlab("Block") + ylab("Mixed durations (s)") +
  facet_wrap(~group) +
  theme_pubclean() +
  geom_boxplot(outlier.alpha = 0) +
  geom_jitter(position = position_jitter(width = 0.08),
              alpha = alphaval) +
  theme(legend.position = "none", 
        text = element_text(size=font_size), 
        plot.caption = element_text(size = font_size),
        plot.tag = element_text(size = font_size, face = "bold")) #+
  # scale_color_grey()

###########################################
### plot dominance durations without outliers
md.plot <- filter(medriv_data, 
                  subjcode!=4148, subjcode!=4158) %>% 
  group_by(group, subj, block) %>%
  summarise(mixmedian = mean(mixmedian))
md.plot$paired <- rep((1:24),each=3)

gp.mix <- ggplot(md.plot, aes(x = block, y = mixmedian)) +
  xlab("Block") + ylab("Mixed durations (s)") +
  facet_wrap(~group) +
  theme_pubclean() +
  geom_boxplot(outlier.alpha = 0) +
  # geom_line(aes(group = paired), position = position_dodge(0.2),
  #           color="grey") +
  geom_point(aes(group = paired), position = position_dodge(0.2),
             alpha = alphaval) +
  # geom_jitter(position = position_jitter(width = 0.08),
  #             alpha = alphaval) +
  theme(legend.position = "none", 
        text = element_text(size=font_size), 
        plot.caption = element_text(size = font_size),
        plot.tag = element_text(size = font_size, face = "bold")) +
  scale_color_grey()
gp.mix
  
ycomp <- 6
astsize <- 4
labtext1 = data.frame(  label = c("p < 0.001", "p = 0.93"),  group = c("Meditators", "Controls"))
my_comparisons <- list(c("BR1", "BR2"))
gp.mix <- gp.mix + stat_compare_means(comparisons = my_comparisons, 
                                              label.y = ycomp, method = "wilcox.test",
                                              na.rm = TRUE, paired = TRUE,
                                              symnum.args = symnum.args, tip.length = .01) +
  geom_text(data = labtext1, mapping =aes(x=1.5, y=ycomp+.3, label=label),
            size = astsize, colour = "black") 

gp.mix


##### stats on mix durations
md.aov <- lmer(mixmedian ~ group*block + (1|subj), 
                    md.plot)
plot(md.aov)

md.aov <- glmer(mixmedian ~ group*block + (1|subj), 
                     md.plot, family = Gamma("identity"))
plot(md.aov)

md.aov <- glmer(mixmedian ~ group*block + (1|subj), 
                md.plot, family = Gamma("identity"))
plot(md.aov)

md.aov <- glmer(mixmedian ~ group*block + (1|subj), 
                     md.plot, family = gaussian("log"))
plot(md.aov)
Anova(md.aov)

lsmeans(md.aov, pairwise ~ block|group)$contrasts
emmeans::emmeans(md.aov, pairwise ~ block|group)$contrasts
lsmeans(md.aov, pairwise ~ group|block)$contrasts

median(md.plot$mixmedian) + 3*sd(md.plot$mixmedian)

md.plot <- filter(medriv_data, subjcode!=4165,
                  subjcode!=4148, subjcode!=4158) %>% 
  group_by(group, subj, block) %>%
  summarise(mixmedian = mean(mixmedian))
md.aov <- glmer(mixmedian ~ group*block + (1|subj), 
                md.plot, family = gaussian("log"))
plot(md.aov)
Anova(md.aov)
lsmeans(md.aov, pairwise ~ block|group)$contrasts


gp.dom <- gp.dom + labs(tag = "A")
gp.mix <- gp.mix + labs(tag = "B")
# hlay <- rbind(c(1,1,1,1,1,1,1,NA,2,2,2,2,2,2,2),
#               c(1,1,1,1,1,1,1,NA,2,2,2,2,2,2,2),
#               c(1,1,1,1,1,1,1,NA,2,2,2,2,2,2,2),
#               c(1,1,1,1,1,1,1,NA,2,2,2,2,2,2,2))
# grid.arrange(grobs = list(gp.dom, gp.mix), 
#              layout_matrix = hlay) # fig 1 7x6 inch pdf
grid.arrange(grobs = list(gp.dom, gp.mix), 
             ncol = 1) # fig 1 3.5x6.2 inch pdf


gp.dom.nol <- gp.dom.nol + labs(tag = "A")
gp.mix.nol <- gp.mix.nol + labs(tag = "B")
hlay <- rbind(c(1,1,1,1,1,1,1,NA,2,2,2,2,2,2,2),
              c(1,1,1,1,1,1,1,NA,2,2,2,2,2,2,2),
              c(1,1,1,1,1,1,1,NA,2,2,2,2,2,2,2),
              c(1,1,1,1,1,1,1,NA,2,2,2,2,2,2,2))
grid.arrange(grobs = list(gp.dom.nol, gp.mix.nol),
             layout_matrix = hlay) # fig 1 7x6 inch pdf


###########################################
## correlate mixed and gamma

chancons <- read.csv(
  '~/OneDrive/Projects/Experiments/Meditation_Rivalry/Data/channel_connections.csv',
  header = TRUE, sep = ',')

### read the data file and initialise the factors
medriv_data = read.csv(
  '~/OneDrive/Projects/Experiments/Meditation_Rivalry/Data/wpli_blockwise_gamma.csv',
  header = TRUE, sep = ',')


medriv_data <- medriv_data %>%
  mutate_if(is.integer, as.factor) %>%
  mutate(block = recode_factor(block, "1" = "BR1", "2" = "BR2", "3" = "BR3"),
         group = recode_factor(group, "1" = "Meditators", "2" = "Controls")) #%>%



# 
# chfrom = c('F6')
# chto = c('P4')
# allcons <- (chancons$chanto %in% chto) & (chancons$chanfrom %in% chfrom)
# 
# md.plot <- filter(medriv_data, connum %in% which(allcons), 
#                   subjcode!=4148, subjcode!=4158) %>%
#   group_by(group, subj, block) %>%
#   summarise(wpli = mean(wpli),
#             mixdurs = mean(mixmedian)) %>%
#   multi_spread(block, c(wpli, mixdurs)) %>%
#   mutate(mixdurs_diff1 = BR2_mixdurs - BR1_mixdurs,
#          wpli_diff1 = BR2_wpli - BR1_wpli)
# pow.cor <- cor.test(x = md.plot$wpli_diff1, y = md.plot$mixdurs_diff1, 
#                     method = "kendall")
# tt <- sprintf("italic(R) == %0.2f~\", \"~italic(p) == %0.3f", 
#               pow.cor$estimate, pow.cor$p.value)
# ggscatter(md.plot, x = "wpli_diff1", y = "mixdurs_diff1",
#                        # xlab = "\u0394 parietal-occipital gamma synchrony", ylab = "\u0394 mixed duration (s)",
#                        xlab = "Parietal-occipital gamma synchrony", ylab = "Mixed duration (s)",
#                        add.params = list(fill = "lightgray"),
#                        add = "reg.line", conf.int = TRUE) +
#   geom_point(aes(colour = factor(group), shape = factor(group)),
#              size = 3.5) + 
#   labs(color = "Group") +
#   geom_text(label = tt, parse = TRUE,
#             x = -.01, y = -1.8) +
#   theme(legend.position = "none", 
#         text = element_text(size=font_size), 
#         plot.caption = element_text(size = font_size),
#         plot.tag = element_text(size = font_size, face = "bold")) +
#   scale_y_continuous(breaks=seq(-2.5,2.5,by=2.5)) #+



# medriv_data$mixmedian[medriv_data$mixmedian==0] = 0.2; ## GLM does not like 0 values of duration

### first get p value of the 2 sets correlations and fdr correct them
pcor = c()
chfrom = c('P3', 'P4', 'P7', 'P8','O1', 'O2', 'Oz')
chto = c('P3', 'P4', 'P7', 'P8','O1', 'O2', 'Oz')
allcons <- (chancons$chanto %in% chto) & (chancons$chanfrom %in% chfrom)

md.plot <- filter(medriv_data, connum %in% which(allcons),
                  subjcode!=4148, subjcode!=4158) %>%
  group_by(group, subj, block) %>%
  summarise(wpli = mean(wpli),
            mixdurs = mean(mixmedian)) %>%
  multi_spread(block, c(wpli, mixdurs)) %>%
  mutate(mixdurs_diff1 = BR2_mixdurs - BR1_mixdurs,
         wpli_diff1 = BR2_wpli - BR1_wpli)
cor <- cor.test(x = md.plot$wpli_diff1, y = md.plot$mixdurs_diff1, 
                    method = "kendall")
pcor[1] <- cor$p.value

chfrom = c('F3', 'F4', 'F7', 'F8', 'P3', 'P4', 'P7', 'P8')
chto = c('F3', 'F4', 'F7', 'F8', 'P3', 'P4', 'P7', 'P8')
allcons <- (chancons$chanto %in% chto) & (chancons$chanfrom %in% chfrom)
md.plot <- filter(medriv_data, connum %in% which(allcons),
                  subjcode!=4148, subjcode!=4158) %>%
  group_by(group, subj, block) %>%
  summarise(wpli = mean(wpli),
            mixdurs = mean(mixmedian)) %>%
  multi_spread(block, c(wpli, mixdurs)) %>%
  mutate(mixdurs_diff1 = BR2_mixdurs - BR1_mixdurs,
         wpli_diff1 = BR2_wpli - BR1_wpli)
cor <- cor.test(x = md.plot$wpli_diff1, y = md.plot$mixdurs_diff1, 
                    method = "kendall")
pcor[2] <- cor$p.value
pcor=2*p.adjust(pcor)
pcor
#################
#### plot parietal-occipital correlation

chfrom = c('P3', 'P4', 'P7', 'P8','O1', 'O2', 'Oz')
chto = c('P3', 'P4', 'P7', 'P8','O1', 'O2', 'Oz')
allcons <- (chancons$chanto %in% chto) & (chancons$chanfrom %in% chfrom)

md.plot <- filter(medriv_data, connum %in% which(allcons), 
                  subjcode!=4148, subjcode!=4158) %>%
  group_by(group, subj, block) %>%
  summarise(wpli = mean(wpli),
            mixdurs = mean(mixmedian)) %>%
  multi_spread(block, c(wpli, mixdurs)) %>%
  mutate(mixdurs_diff1 = BR2_mixdurs - BR1_mixdurs,
         wpli_diff1 = BR2_wpli - BR1_wpli)
pow.cor <- cor.test(x = md.plot$wpli_diff1, y = md.plot$mixdurs_diff1, 
                    method = "kendall")
tt <- sprintf("italic(R) == %0.2f~\", \"~italic(p) == %0.3f", 
              pow.cor$estimate, pcor[1])
gp.po.gam <- ggscatter(md.plot, x = "wpli_diff1", y = "mixdurs_diff1",
          # xlab = "\u0394 parietal-occipital gamma synchrony", ylab = "\u0394 mixed duration (s)",
          xlab = "Parietal-occipital gamma synchrony", ylab = "Mixed duration (s)",
          add.params = list(fill = "lightgray"),
          add = "reg.line", conf.int = TRUE) +
  geom_point(aes(colour = factor(group), shape = factor(group)),
             size = 3) + 
  labs(color = "Group") +
  geom_text(label = tt, parse = TRUE,
            x = .0, y = -1.8) +
  theme(legend.position = "none", 
        text = element_text(size=font_size), 
        plot.caption = element_text(size = font_size),
        plot.tag = element_text(size = font_size, face = "bold")) +
  scale_y_continuous(breaks=seq(-2.5,2.5,by=2.5)) +
  scale_color_grey(start = 0, end = .4  )

gp.po.gam

md.plot.gp <- filter(md.plot, group=="Meditators")
cor.test(x = md.plot.gp$wpli_diff1, y = md.plot.gp$mixdurs_diff1,
         method = "kendall")
md.plot.gp <- filter(md.plot, group=="Controls")
cor.test(x = md.plot.gp$wpli_diff1, y = md.plot.gp$mixdurs_diff1,
         method = "kendall")

####

chfrom = c('F3', 'F4', 'F7', 'F8', 'P3', 'P4', 'P7', 'P8')
chto = c('F3', 'F4', 'F7', 'F8', 'P3', 'P4', 'P7', 'P8')
allcons <- (chancons$chanto %in% chto) & (chancons$chanfrom %in% chfrom)

md.plot <- filter(medriv_data, connum %in% which(allcons),
                  subjcode!=4148, subjcode!=4158) %>%
  group_by(group, subj, block) %>%
  summarise(wpli = mean(wpli),
            mixdurs = mean(mixmedian)) %>%
  multi_spread(block, c(wpli, mixdurs)) %>%
  mutate(mixdurs_diff1 = BR2_mixdurs - BR1_mixdurs,
         wpli_diff1 = BR2_wpli - BR1_wpli)
pow.cor <- cor.test(x = md.plot$wpli_diff1, y = md.plot$mixdurs_diff1, method = "kendall")
tt <- sprintf("italic(R) == %0.2f~\", \"~italic(p) == %0.3f", 
              pow.cor$estimate, pcor[2])
gp.fp.gam <- ggscatter(md.plot, x = "wpli_diff1", y = "mixdurs_diff1",
          xlab = "Frontal-parietal gamma synchrony", ylab = "Mixed duration (s)",
          add.params = list(fill = "lightgray"),
          add = "reg.line", conf.int = TRUE) +
  geom_point(aes(colour = factor(group), shape = factor(group)),
             size = 3) + 
  geom_text(label = tt, parse = TRUE,
            x = -.00, y = -2) +
  theme(legend.position = "none", 
        text = element_text(size=font_size), 
        plot.caption = element_text(size = font_size),
        plot.tag = element_text(size = font_size, face = "bold")) +
  scale_y_continuous(breaks=seq(-2.5,2.5,by=2.5)) +
  scale_color_grey(start = 0, end = .4 )
gp.fp.gam

md.plot.gp <- filter(md.plot, group=="Meditators")
cor.test(x = md.plot.gp$wpli_diff1, y = md.plot.gp$mixdurs_diff1,
         method = "kendall")
md.plot.gp <- filter(md.plot, group=="Controls")
cor.test(x = md.plot.gp$wpli_diff1, y = md.plot.gp$mixdurs_diff1,
         method = "kendall")


### beta synchrony

### read the data file and initialise the factors
medriv_data = read.csv(
  '~/OneDrive/Projects/Experiments/Meditation_Rivalry/Data/wpli_blockwise_beta.csv',
  header = TRUE, sep = ',')
# chancons <- read.csv(
#   '~/OneDrive/Projects/Experiments/Meditation_Rivalry/Data/channel_connections.csv',
#   header = TRUE, sep = ',')


medriv_data <- medriv_data %>%
  mutate_if(is.integer, as.factor) %>%
  mutate(block = recode_factor(block, "1" = "BR1", "2" = "BR2", "3" = "BR3"),
         group = recode_factor(group, "1" = "Meditators", "2" = "Controls")) #%>%


medriv_data$mixmedian[medriv_data$mixmedian==0] = 0.2; ## GLM does not like 0 values of duration


### first get p value of the 2 sets correlations and fdr correct them
pcor = c()
chfrom = c('P3', 'P4', 'P7', 'P8','O1', 'O2', 'Oz')
chto = c('P3', 'P4', 'P7', 'P8','O1', 'O2', 'Oz')
allcons <- (chancons$chanto %in% chto) & (chancons$chanfrom %in% chfrom)

md.plot <- filter(medriv_data, connum %in% which(allcons),
                  subjcode!=4148, subjcode!=4158) %>%
  group_by(group, subj, block) %>%
  summarise(wpli = mean(wpli),
            mixdurs = mean(mixmedian)) %>%
  multi_spread(block, c(wpli, mixdurs)) %>%
  mutate(mixdurs_diff1 = BR2_mixdurs - BR1_mixdurs,
         wpli_diff1 = BR2_wpli - BR1_wpli)
cor <- cor.test(x = md.plot$wpli_diff1, y = md.plot$mixdurs_diff1, 
                method = "kendall")
pcor[1] <- cor$p.value

chfrom = c('F3', 'F4', 'F7', 'F8', 'P3', 'P4', 'P7', 'P8')
chto = c('F3', 'F4', 'F7', 'F8', 'P3', 'P4', 'P7', 'P8')
allcons <- (chancons$chanto %in% chto) & (chancons$chanfrom %in% chfrom)
md.plot <- filter(medriv_data, connum %in% which(allcons),
                  subjcode!=4148, subjcode!=4158) %>%
  group_by(group, subj, block) %>%
  summarise(wpli = mean(wpli),
            mixdurs = mean(mixmedian)) %>%
  multi_spread(block, c(wpli, mixdurs)) %>%
  mutate(mixdurs_diff1 = BR2_mixdurs - BR1_mixdurs,
         wpli_diff1 = BR2_wpli - BR1_wpli)
cor <- cor.test(x = md.plot$wpli_diff1, y = md.plot$mixdurs_diff1, 
                method = "kendall")
pcor[2] <- cor$p.value
pcor=2*p.adjust(pcor)
pcor

chfrom = c('P3', 'P4', 'P7', 'P8','O1', 'O2', 'Oz')
chto = c('P3', 'P4', 'P7', 'P8','O1', 'O2', 'Oz')

allcons <- (chancons$chanto %in% chto) & (chancons$chanfrom %in% chfrom)

md.plot <- filter(medriv_data, connum %in% which(allcons),
                  subjcode!=4148, subjcode!=4158) %>%
  group_by(group, subj, block) %>%
  summarise(wpli = mean(wpli),
            mixdurs = mean(mixmedian)) %>%
  multi_spread(block, c(wpli, mixdurs)) %>%
  mutate(mixdurs_diff1 = BR2_mixdurs - BR1_mixdurs,
         wpli_diff1 = BR2_wpli - BR1_wpli)
pow.cor <- cor.test(x = md.plot$wpli_diff1, y = md.plot$mixdurs_diff1, 
                    method = "kendall")
tt <- sprintf("italic(R) == %0.2f~\", \"~italic(p) == %0.3f", 
              pow.cor$estimate, 1)
gp.po.bet <- ggscatter(md.plot, x = "wpli_diff1", y = "mixdurs_diff1",
          xlab = "Parietal-occipital beta synchrony", ylab = "Mixed duration (s)",
          add.params = list(fill = "lightgray"),
          add = "reg.line", conf.int = TRUE) +
  geom_point(aes(colour = factor(group), shape = factor(group)),
             size = 3) + 
  labs(color = "Group") +
  geom_text(label = tt, parse = TRUE,
            x = .005, y = -2.2) +
  theme(legend.position = "none", 
        text = element_text(size=font_size), 
        plot.caption = element_text(size = font_size),
        plot.tag = element_text(size = font_size, face = "bold")) +
  scale_y_continuous(breaks=seq(-2.5,2.5,by=2.5))  +
  scale_color_grey(start = 0, end = .4 )
gp.po.bet


#### frontal

chfrom = c('F3', 'F4', 'F7', 'F8', 'P3', 'P4', 'P7', 'P8')
chto = c('F3', 'F4', 'F7', 'F8', 'P3', 'P4', 'P7', 'P8')
allcons <- (chancons$chanto %in% chto) & (chancons$chanfrom %in% chfrom)

md.plot <- filter(medriv_data, connum %in% which(allcons),
                  subjcode!=4148, subjcode!=4158) %>%
  group_by(group, subj, block) %>%
  summarise(wpli = mean(wpli),
            mixdurs = mean(mixmedian)) %>%
  multi_spread(block, c(wpli, mixdurs)) %>%
  mutate(mixdurs_diff1 = BR2_mixdurs - BR1_mixdurs,
         wpli_diff1 = BR2_wpli - BR1_wpli)
pow.cor <- cor.test(x = md.plot$wpli_diff1, y = md.plot$mixdurs_diff1, 
                    method = "kendall")
tt <- sprintf("italic(R) == %0.2f~\", \"~italic(p) == %0.3f", 
              pow.cor$estimate, 1)
gp.fp.bet <- ggscatter(md.plot, x = "wpli_diff1", y = "mixdurs_diff1",
          xlab = "Frontal-parietal beta synchrony", ylab = "Mixed duration (s)",
          add.params = list(fill = "lightgray"),
          add = "reg.line", conf.int = TRUE) +
  geom_point(aes(colour = factor(group), shape = factor(group)),
             size = 3) + 
  labs(color = "Group") +
  geom_text(label = tt, parse = TRUE,
            x = .001, y = -2.2) +
  theme(legend.position = "none", 
        text = element_text(size=font_size), 
        plot.caption = element_text(size = font_size),
        plot.tag = element_text(size = font_size, face = "bold")) +
  scale_y_continuous(breaks=seq(-2.5,2.5,by=2.5)) +
  scale_color_grey(start = 0, end = .4 )
gp.fp.bet


gp.po.gam <- gp.po.gam + labs(tag = "A")
gp.fp.gam <- gp.fp.gam + labs(tag = "B")
gp.po.bet <- gp.po.bet + labs(tag = "C")
gp.fp.bet <- gp.fp.bet + labs(tag = "D")
# hlay <- rbind(c(1,1,1,1,1,1,1,NA,2,2,2,2,2,2,2),
#               c(1,1,1,1,1,1,1,NA,2,2,2,2,2,2,2),
#               c(1,1,1,1,1,1,1,NA,2,2,2,2,2,2,2),
#               c(1,1,1,1,1,1,1,NA,2,2,2,2,2,2,2),
#               c(3,3,3,3,3,3,3,NA,4,4,4,4,4,4,4),
#               c(3,3,3,3,3,3,3,NA,4,4,4,4,4,4,4),
#               c(3,3,3,3,3,3,3,NA,4,4,4,4,4,4,4),
#               c(3,3,3,3,3,3,3,NA,4,4,4,4,4,4,4))
hlay <- rbind(c(1,1,1,1,1,1,1,2,2,2,2,2,2,2),
              c(1,1,1,1,1,1,1,2,2,2,2,2,2,2),
              c(1,1,1,1,1,1,1,2,2,2,2,2,2,2),
              c(1,1,1,1,1,1,1,2,2,2,2,2,2,2),
              c(3,3,3,3,3,3,3,4,4,4,4,4,4,4),
              c(3,3,3,3,3,3,3,4,4,4,4,4,4,4),
              c(3,3,3,3,3,3,3,4,4,4,4,4,4,4),
              c(3,3,3,3,3,3,3,4,4,4,4,4,4,4))
grid.arrange(grobs = list(gp.po.gam, gp.fp.gam,
                          gp.po.bet, gp.fp.bet), 
             nrow = 2, layout_matrix = hlay) # fig 1 7x6 inch pdf


####
#### control analysis
### exclude data around the transitions
medriv_data = read.csv(
  '~/OneDrive/Projects/Experiments/Meditation_Rivalry/Data/wpli_blockwise_gamma_notrans.csv',
  header = TRUE, sep = ',')

# assign factors as factors
medriv_data <- medriv_data %>%
  mutate_if(is.integer, as.factor) %>%
  mutate(block = recode_factor(block, "1" = "BR1", "2" = "BR2", "3" = "BR3"),
         group = recode_factor(group, "1" = "Meditators", "2" = "Controls")) #%>%

chfrom = c('P3', 'P4', 'P7', 'P8','O1', 'O2', 'Oz')
chto = c('P3', 'P4', 'P7', 'P8','O1', 'O2', 'Oz')

###########################################
## correlate parietal-occipital connectivity with mix durations
allcons <- (chancons$chanto %in% chto) & (chancons$chanfrom %in% chfrom)
# 
md.plot <- filter(medriv_data, connum %in% which(allcons),
                  subjcode!=4148, subjcode!=4158) %>%
  group_by(group, subj, block) %>%
  summarise(wpli = mean(wpli),
            mixdurs = mean(mixmedian)) %>%
  multi_spread(block, c(wpli, mixdurs)) %>%
  mutate(mixdurs_diff1 = BR2_mixdurs - BR1_mixdurs,
         wpli_diff1 = BR2_wpli - BR1_wpli)
pow.cor <- cor.test(x = md.plot$wpli_diff1, y = md.plot$mixdurs_diff1, method = "kendall")
tt <- sprintf("italic(R) == %0.2f~\", \"~italic(p) == %0.3f", 
              pow.cor$estimate, pow.cor$p.value)
ggscatter(md.plot, x = "wpli_diff1", y = "mixdurs_diff1",
          xlab = "\u0394 Parieto-occipital synchrony", ylab = "\u0394 Mixed duration (s)",
          add = "reg.line", conf.int = TRUE) +
  geom_point(aes(colour = factor(group))) + labs(color = "Group") +
  geom_text(label = tt, parse = TRUE,
            x = .03, y = 3) +
  scale_color_grey()

md.plot.gp <- filter(md.plot, group=="Meditators")

cor.test(x = md.plot.gp$wpli_diff1, y = md.plot.gp$mixdurs_diff1,
         method = "kendall")
md.plot.gp <- filter(md.plot, group=="Controls")
cor.test(x = md.plot.gp$wpli_diff1, y = md.plot.gp$mixdurs_diff1,
         method = "kendall")


### only include data around the transitions
medriv_data = read.csv(
  '~/OneDrive/Projects/Experiments/Meditation_Rivalry/Data/wpli_blockwise_gamma_trans.csv',
  header = TRUE, sep = ',')

# assign factors as factors
medriv_data <- medriv_data %>%
  mutate_if(is.integer, as.factor) %>%
  mutate(block = recode_factor(block, "1" = "BR1", "2" = "BR2", "3" = "BR3"),
         group = recode_factor(group, "1" = "Meditators", "2" = "Controls")) #%>%

chfrom = c('P3', 'P4', 'P7', 'P8','O1', 'O2', 'Oz')
chto = c('P3', 'P4', 'P7', 'P8','O1', 'O2', 'Oz')

###########################################
## correlate parietal-occipital connectivity with mix durations
allcons <- (chancons$chanto %in% chto) & (chancons$chanfrom %in% chfrom)
# 
md.plot <- filter(medriv_data, connum %in% which(allcons),
                  subjcode!=4148, subjcode!=4158) %>%
  group_by(group, subj, block) %>%
  summarise(wpli = mean(wpli),
            mixdurs = mean(mixmedian)) %>%
  multi_spread(block, c(wpli, mixdurs)) %>%
  mutate(mixdurs_diff1 = BR2_mixdurs - BR1_mixdurs,
         wpli_diff1 = BR2_wpli - BR1_wpli)
cor.test(x = md.plot$wpli_diff1, y = md.plot$mixdurs_diff1, method = "kendall")



### do the control analysis for only the dominance periods
medriv_data = read.csv(
  '~/OneDrive/Projects/Experiments/Meditation_Rivalry/Data/wpli_blockwise_gamma_dom.csv',
  header = TRUE, sep = ',')

# assign factors as factors
medriv_data <- medriv_data %>%
  mutate_if(is.integer, as.factor) %>%
  mutate(block = recode_factor(block, "1" = "BR1", "2" = "BR2", "3" = "BR3"),
         group = recode_factor(group, "1" = "Meditators", "2" = "Controls")) #%>%


chfrom = c('P3', 'P4', 'P7', 'P8','O1', 'O2', 'Oz')
chto = c('P3', 'P4', 'P7', 'P8','O1', 'O2', 'Oz')

###########################################
## correlate parietal-occipital connectivity with mix durations
allcons <- (chancons$chanto %in% chto) & (chancons$chanfrom %in% chfrom)
# 
md.plot <- filter(medriv_data, connum %in% which(allcons),
                  subjcode!=4148, subjcode!=4158) %>%
  group_by(group, subj, block) %>%
  summarise(wpli = mean(wpli),
            mixdurs = mean(mixmedian)) %>%
  multi_spread(block, c(wpli, mixdurs)) %>%
  mutate(mixdurs_diff1 = BR2_mixdurs - BR1_mixdurs,
         wpli_diff1 = BR2_wpli - BR1_wpli) %>%
  select(-c(starts_with("BR")))
md.plot <- na.omit(md.plot)

cor.test(x = md.plot$wpli_diff1, y = md.plot$mixdurs_diff1, method = "kendall")
# tt <- sprintf("italic(R) == %0.2f~\", \"~italic(p) == %0.3f", 
#               pow.cor$estimate, pow.cor$p.value)
# ggscatter(md.plot, x = "wpli_diff1", y = "mixdurs_diff1",
#           xlab = "\u0394 Parieto-occipital synchrony", ylab = "\u0394 Mixed duration (s)",
#           add = "reg.line", conf.int = TRUE) +
#   geom_point(aes(colour = factor(group))) + labs(color = "Group") +
#   geom_text(label = tt, parse = TRUE,
#             x = .025, y = 3) +
#   scale_color_grey()



### do the control analysis for only the dominance periods
medriv_data = read.csv(
  '~/OneDrive/Projects/Experiments/Meditation_Rivalry/Data/wpli_blockwise_gamma_mix.csv',
  header = TRUE, sep = ',')
# chancons <- read.csv(
#   '~/OneDrive/Projects/Experiments/Meditation_Rivalry/Data/channel_connections.csv',
#   header = TRUE, sep = ',')

# assign factors as factors
medriv_data <- medriv_data %>%
  mutate_if(is.integer, as.factor) %>%
  mutate(block = recode_factor(block, "1" = "BR1", "2" = "BR2", "3" = "BR3"),
         group = recode_factor(group, "1" = "Meditators", "2" = "Controls")) #%>%

# medriv_data$mixmedian[medriv_data$mixmedian==0] = 0.2; ## GLM does not like 0 values of duration
###########################################
## GLMM on lateral parietal with occipital synchrony 

chfrom = c('P3', 'P4', 'P7', 'P8','O1', 'O2', 'Oz')
chto = c('P3', 'P4', 'P7', 'P8','O1', 'O2', 'Oz')

###########################################
## correlate parietal-occipital connectivity with mix durations
allcons <- (chancons$chanto %in% chto) & (chancons$chanfrom %in% chfrom)
# 
md.plot <- filter(medriv_data, connum %in% which(allcons),
                  subjcode!=4148, subjcode!=4158) %>%
  group_by(group, subj, block) %>%
  summarise(wpli = mean(wpli),
            mixdurs = mean(mixmedian)) %>%
  multi_spread(block, c(wpli, mixdurs)) %>%
  mutate(mixdurs_diff1 = BR2_mixdurs - BR1_mixdurs,
         wpli_diff1 = BR2_wpli - BR1_wpli) %>%
  select(-c(starts_with("BR")))
md.plot <- na.omit(md.plot)

cor.test(x = md.plot$wpli_diff1, y = md.plot$mixdurs_diff1, method = "kendall")
# tt <- sprintf("italic(R) == %0.2f~\", \"~italic(p) == %0.3f", 
#               pow.cor$estimate, pow.cor$p.value)
# ggscatter(md.plot, x = "wpli_diff1", y = "mixdurs_diff1",
#           xlab = "\u0394 Parieto-occipital synchrony", ylab = "\u0394 Mixed duration (s)",
#           add = "reg.line", conf.int = TRUE) +
#   geom_point(aes(colour = factor(group))) + labs(color = "Group") +
#   geom_text(label = tt, parse = TRUE,
#             x = .025, y = 3) +
#   scale_color_grey()
