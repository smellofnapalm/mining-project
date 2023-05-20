% MINING
% A mining company is going to continue operating in a certain area for the next
% several years. There are four mines in this area, but it can operate limited number in any
% one year. Although a mine may not operate in a certain year, it is still necessary to
% keep it ‘open’, in the sense that royalties are payable, if it be operated in a future
% year. Clearly, if a mine is not going to be worked again, it can be permanently
% closed down and no more royalties need be paid.
% There is an upper limit to the amount of ore, which can be extracted from
% each mine in a year.
% The ore from the different mines is of varying quality. This quality is measured
% on a scale so that blending ores together results in a linear combination
% of the quality measurements, for example, if equal quantities of two ores were
% combined, the resultant ore would have a quality measurement half way between
% that of the ingredient ores.
% In each year, it is necessary to combine the total outputs from each mine to
% produce a blended ore of exactly some stipulated quality.
% Revenue and royalties for are discounted in years with given discount factor.

% Decide which mines should be operated each year and
% how much they should produce.
% Objective - maximize (Total Revenue) - (Total Royalties), where
% Total Revenue = sum over years of (revenue obtained from selling blended ore multplied by year discount factor)
% Total Royealties = sum over years of (royalties payd for opened mines multiplied by year discount factor)

% DATA
% Number of mines
int: NbMines;
% Number of years
int: NbYears;
% Max number of mines can operate per year
float: LimWork;
% Cost of blended ore
float: BlendPrice;
% Yearly royalties 
array[1..NbMines] of float: Royalties;
% Upper limit to the amount of ore
array[1..NbMines] of float: LimExtract;
% Ore quality
array[1..NbMines] of float: OreQual;
% Blend quality
array[1..NbYears] of float: BlendQual;
% Discount factor
array[1..NbYears] of float: DiscountFactor;
% DATA TEST

array[1..NbYears] of var float: BlendedOre :: add_to_output;
array[1..NbYears, 1..NbMines] of var float: MinedOre :: add_to_output;
array[1..NbYears, 1..NbMines] of var 0..1: MineAtWork :: add_to_output;
array[1..NbYears, 1..NbMines] of var 0..1: MineOpened :: add_to_output;
var float: target :: add_to_output = sum(t in 1..NbYears, m in 1..NbMines)(DiscountFactor[t]*(BlendPrice*BlendedOre[t] - Royalties[m]*MinedOre[t,m]));

constraint forall(t in 1..NbYears, m in 1..NbMines)(MinedOre[t, m] >= 0.0);

% constraint for num of working mines
constraint forall(t in 1..NbYears)(sum(m in  1..NbMines)(MineAtWork[t, m]) <= LimWork);
% we have to achive quality
constraint forall(t in 1..NbYears)(sum(m in 1..NbMines)(OreQual[m]*MinedOre[t, m]) == BlendQual[t]*BlendedOre[t]);
% tons of extracted ore equal to tons of blended ore
constraint forall(t in 1..NbYears)(sum(m in 1..NbMines)(MinedOre[t, m]) == BlendedOre[t]);
% we cannot extract from mine more than LimExtract
constraint forall(t in 1..NbYears, m in 1..NbMines)(MinedOre[t, m] <= LimExtract[m] * MineAtWork[t, m]);
% mine can be used iff it is open
constraint forall(t in 1..NbYears, m in 1..NbMines)(MineAtWork[t, m] <= MineOpened[t, m]);
% if we close mine, we cannot use it anymore
constraint forall(t in 1..NbYears-1, m in 1..NbMines)(MineOpened[t+1, m] <= MineOpened[t, m]);
% if mine will no longer work, then it is close
constraint forall(t in 1..NbYears, m in 1..NbMines)
(forall(n in t..NbYears)(MineAtWork[n, m] = 0) -> MineOpened[t, m] = 0);

solve maximize target;