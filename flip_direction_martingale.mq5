//+------------------------------------------------------------------+
//|                                    flip_direction_martingale.mq5 |
//|                                                             Tarn |
//|                             https://github.com/BTarn/port-blower |
//|Original idea and code from: https://youtu.be/-cXaqL5KfdE         |
//+------------------------------------------------------------------+


#property copyright "Tarn"
#property link      "https://github.com/BTarn/port-blower"
#property version   "1.00"
#property description "Original idea and code from: https://youtu.be/-cXaqL5KfdE"

#include <Trade/Trade.mqh>


uint buy_with_magic_number = 0;
uint sell_with_magic_number = 0;
uint position_with_magic_number = 0;
uint lotFactor = 1;

double stopLoss = 0;
double this_round_profit = 0;
double trailing_profit = 0;

ulong posTicket;

bool buy_side = true;
bool stop_trailing = false;


input double lotSize = 0.01; // Trading lot size
input ulong magic_number = 13;
input double range_width = 260;


CTrade trade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   trade.SetExpertMagicNumber(magic_number);

   MathSrand(GetTickCount());

   int randomDecision = MathRand()%2;

   if(randomDecision == 1)
     {
      buy_side = false;
     }

// resetCounter();

// flipDirectionMartingale();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   resetCounter();

   flipDirectionMartingale();

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void resetCounter()
  {
   buy_with_magic_number = 0;
   sell_with_magic_number = 0;
   position_with_magic_number = 0;
   for(int i=0 ; i <= PositionsTotal()-1 ; i++)
     {
      PositionSelectByTicket(PositionGetTicket(i));

      if((PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) && (PositionGetInteger(POSITION_MAGIC) == magic_number))
        {
         buy_with_magic_number++;
         position_with_magic_number++;
         posTicket = PositionGetTicket(i);
        }
      if((PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) && (PositionGetInteger(POSITION_MAGIC) == magic_number))
        {
         sell_with_magic_number++;
         position_with_magic_number++;
         posTicket = PositionGetTicket(i);
        }

     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void flipDirectionMartingale()
  {
   double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);

   ask = NormalizeDouble(ask,Digits());
   bid = NormalizeDouble(bid,Digits());

   if(position_with_magic_number == 0)
     {
      if(buy_side)
        {
         trade.Buy(lotSize);
        }
      else
        {
         trade.Sell(lotSize);
        }
     }
   else
     {
      if(buy_with_magic_number > 0)
        {
         PositionSelectByTicket(posTicket);
         if(PositionGetDouble(POSITION_PRICE_CURRENT) - PositionGetDouble(POSITION_PRICE_OPEN) <= (-1 * range_width * Point()))
           {
            this_round_profit += PositionGetDouble(POSITION_PROFIT);
            trade.PositionClose(posTicket);
            lotFactor = lotFactor * 2;

            double lot = lotSize * lotFactor;

            lot = NormalizeDouble(lot, Digits());
            trade.Sell(lot);
           }
         else
           {
            //            if(PositionGetDouble(POSITION_PROFIT) >= (range_width * Point()))
            if(PositionGetDouble(POSITION_PRICE_CURRENT) - PositionGetDouble(POSITION_PRICE_OPEN) >= (range_width * Point()))
              {
               if(PositionGetDouble(POSITION_PROFIT) + this_round_profit > trailing_profit)
                 {
                  trailing_profit = PositionGetDouble(POSITION_PROFIT) + this_round_profit;
                  stop_trailing = true;
                 }
               else
                 {
                  trade.PositionClose(posTicket);
                  trade.Sell(lotSize);
                  this_round_profit = 0;
                  lotFactor = 1;
                  trailing_profit = 0;
                  stop_trailing = false;
                 }
              }
           }
         if(stop_trailing)
           {
            trade.PositionClose(posTicket);
            trade.Sell(lotSize);
            this_round_profit = 0;
            lotFactor = 1;
            trailing_profit = 0;
            stop_trailing = false;
           }
        }
      else
        {
         if(sell_with_magic_number > 0)
           {
            PositionSelectByTicket(posTicket);
            if(PositionGetDouble(POSITION_PRICE_CURRENT) - PositionGetDouble(POSITION_PRICE_OPEN) >= (range_width * Point()))
              {
               this_round_profit += PositionGetDouble(POSITION_PROFIT);
               trade.PositionClose(posTicket);
               lotFactor = lotFactor * 2;

               double lot = lotSize * lotFactor;

               lot = NormalizeDouble(lot, Digits());
               trade.Buy(lot);
              }
            else
              {
               //               if(PositionGetDouble(POSITION_PROFIT) >= (range_width * Point()))
               if(PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_PRICE_CURRENT) >= (range_width * Point()))
                 {
                  if(PositionGetDouble(POSITION_PROFIT) + this_round_profit > trailing_profit)
                    {
                     trailing_profit = PositionGetDouble(POSITION_PROFIT) + this_round_profit;
                     stop_trailing = true;
                    }
                  else
                    {
                     trade.PositionClose(posTicket);
                     trade.Buy(lotSize);
                     this_round_profit = 0;
                     lotFactor = 1;
                     trailing_profit = 0;
                     stop_trailing = false;
                    }
                 }
              }
            if(stop_trailing)
              {
               trade.PositionClose(posTicket);
               trade.Buy(lotSize);
               this_round_profit = 0;
               lotFactor = 1;
               trailing_profit = 0;
               stop_trailing = false;
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---

  }
//+------------------------------------------------------------------+
