//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_RVI_EURUSD_M15_Params : Stg_RVI_Params {
  Stg_RVI_EURUSD_M15_Params() {
    symbol = "EURUSD";
    tf = PERIOD_M15;
    RVI_Period = 2;
    RVI_Applied_Price = 3;
    RVI_Shift = 0;
    RVI_TrailingStopMethod = 6;
    RVI_TrailingProfitMethod = 11;
    RVI_SignalOpenLevel = 36;
    RVI_SignalBaseMethod = -63;
    RVI_SignalOpenMethod1 = 389;
    RVI_SignalOpenMethod2 = 0;
    RVI_SignalCloseLevel = 36;
    RVI_SignalCloseMethod1 = 1;
    RVI_SignalCloseMethod2 = 0;
    RVI_MaxSpread = 4;
  }
};
