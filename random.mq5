//+------------------------------------------------------------------+
//|                                                       random.mq5 |
//|                                                             Tarn |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Tarn"
#property link      ""
#property version   "2.0"

#include <Trade/Trade.mqh>
// #include <Trade/PositionInfo.mqh>

ulong posTicket;
ulong posTicket_buy;
ulong posTicket_sell;

int buy_with_magic_number = 0;
int sell_with_magic_number = 0;
int position_with_magic_number = 0;

// MqlTick Latest_Price;

CTrade trade;
// CPositionInfo m_position;

input ulong magic_number = 15;

input double lotSize = 0.01; // Trading lot size


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   trade.SetExpertMagicNumber(magic_number);

   resetCounter();

   MathSrand(GetTickCount());

   randomSingleOrder();

// if(PositionsTotal() != 0)
//     {
//    posTicket = PositionGetTicket(0);
// }

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

   randomSingleOrder();
  }
// }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void randomOrder()
  {
   int randomDecision = MathRand()%3;

// Buy if randomDecision is 0, sell if it's 1, do nothing if it's 2.
   if((randomDecision == 0) && (buy_with_magic_number == 0))
     {
      trade.Buy(lotSize);
      if(trade.ResultOrder() > 0)
        {
         posTicket_buy = trade.ResultOrder();
         buy_with_magic_number++;
         position_with_magic_number++;
        }
     }
//else
//   if((randomDecision == 1) && (sell_with_magic_number == 0))
//     {
//      trade.Sell(lotSize);
//      if(trade.ResultOrder() > 0)
//        {
//         posTicket_sell = trade.ResultOrder();
//         sell_count++;
//         position_with_magic_number++;
//        }
//     }
   else
      if((randomDecision == 2) && (buy_with_magic_number > 0))
        {
         PositionSelectByTicket(posTicket_buy);
         if(PositionGetDouble(POSITION_PROFIT) >= 0.02)
           {
            trade.PositionClose(posTicket_buy);
            if(trade.ResultOrder() > 0)
              {
               posTicket_buy = trade.ResultOrder();
               buy_with_magic_number++;
               position_with_magic_number++;
              }
           }
        }
//else
//   if((randomDecision == 3) && (sell_with_magic_number > 0))
//     {
//      PositionSelectByTicket(posTicket_sell);
//      if(PositionGetDouble(POSITION_PROFIT) >= 0.02)
//        {
//         trade.PositionClose(posTicket_sell);
//         if(trade.ResultOrder() > 0)
//           {
//            posTicket_sell = trade.ResultOrder();
//            sell_count--;
//            position_with_magic_number++;
//           }
//        }
//     }
  }

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
         posTicket_buy = PositionGetTicket(i);
         posTicket = PositionGetTicket(i);
        }
      if((PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) && (PositionGetInteger(POSITION_MAGIC) == magic_number))
        {
         sell_with_magic_number++;
         position_with_magic_number++;
         posTicket_sell = PositionGetTicket(i);
         posTicket = PositionGetTicket(i);
        }

     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void randomSingleOrder()
  {
   int randomDecision = MathRand()%2;

   if((randomDecision == 0) && (position_with_magic_number == 0))
     {
      int chooseBuySell = MathRand()%2;

      if(chooseBuySell == 0)
        {
         trade.Buy(lotSize);
        }
      else
         if(chooseBuySell == 1)
           {
            trade.Sell(lotSize);
           }
     }
   else
      if((randomDecision == 1) && (position_with_magic_number > 0))
        {
         PositionSelectByTicket(posTicket);
         if(PositionGetDouble(POSITION_PROFIT) >= 0.02)
           {
            trade.PositionClose(posTicket);
           }
        }
  }


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
