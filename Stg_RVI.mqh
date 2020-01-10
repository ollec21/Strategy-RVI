//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements RVI strategy based on the Relative Vigor Index indicator.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_RVI.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT string __RVI_Parameters__ = "-- RVI strategy params --";  // >>> RVI <<<
INPUT int RVI_Active_Tf = 0;  // Activate timeframes (1-255, e.g. M1=1,M5=2,M15=4,M30=8,H1=16,H2=32...)
INPUT int RVI_Period = 10;    // Period
INPUT ENUM_TRAIL_TYPE RVI_TrailingStopMethod = 22;             // Trail stop method
INPUT ENUM_TRAIL_TYPE RVI_TrailingProfitMethod = 1;            // Trail profit method
INPUT int RVI_Shift = 2;                                       // Shift
INPUT double RVI_SignalOpenLevel = 0.00000000;                 // Signal open level
INPUT int RVI1_SignalBaseMethod = 0;                           // Signal base method (0-
INPUT int RVI1_OpenCondition1 = 0;                             // Open condition 1 (0-1023)
INPUT int RVI1_OpenCondition2 = 0;                             // Open condition 2 (0-)
INPUT ENUM_MARKET_EVENT RVI1_CloseCondition = C_RVI_BUY_SELL;  // Close condition for M1
INPUT double RVI_MaxSpread = 6.0;                              // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_RVI_Params : Stg_Params {
  unsigned int RVI_Period;
  ENUM_APPLIED_PRICE RVI_Applied_Price;
  int RVI_Shift;
  ENUM_TRAIL_TYPE RVI_TrailingStopMethod;
  ENUM_TRAIL_TYPE RVI_TrailingProfitMethod;
  double RVI_SignalOpenLevel;
  long RVI_SignalBaseMethod;
  long RVI_SignalOpenMethod1;
  long RVI_SignalOpenMethod2;
  double RVI_SignalCloseLevel;
  ENUM_MARKET_EVENT RVI_SignalCloseMethod1;
  ENUM_MARKET_EVENT RVI_SignalCloseMethod2;
  double RVI_MaxSpread;

  // Constructor: Set default param values.
  Stg_RVI_Params()
      : RVI_Period(::RVI_Period),
        RVI_Applied_Price(::RVI_Applied_Price),
        RVI_Shift(::RVI_Shift),
        RVI_TrailingStopMethod(::RVI_TrailingStopMethod),
        RVI_TrailingProfitMethod(::RVI_TrailingProfitMethod),
        RVI_SignalOpenLevel(::RVI_SignalOpenLevel),
        RVI_SignalBaseMethod(::RVI_SignalBaseMethod),
        RVI_SignalOpenMethod1(::RVI_SignalOpenMethod1),
        RVI_SignalOpenMethod2(::RVI_SignalOpenMethod2),
        RVI_SignalCloseLevel(::RVI_SignalCloseLevel),
        RVI_SignalCloseMethod1(::RVI_SignalCloseMethod1),
        RVI_SignalCloseMethod2(::RVI_SignalCloseMethod2),
        RVI_MaxSpread(::RVI_MaxSpread) {}
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_RVI : public Strategy {
 public:
  Stg_RVI(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_RVI *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_RVI_Params _params;
    switch (_tf) {
      case PERIOD_M1: {
        Stg_RVI_EURUSD_M1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M5: {
        Stg_RVI_EURUSD_M5_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M15: {
        Stg_RVI_EURUSD_M15_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M30: {
        Stg_RVI_EURUSD_M30_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H1: {
        Stg_RVI_EURUSD_H1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H4: {
        Stg_RVI_EURUSD_H4_Params _new_params;
        _params = _new_params;
      }
    }
    // Initialize strategy parameters.
    ChartParams cparams(_tf);
    RVI_Params adx_params(_params.RVI_Period, _params.RVI_Applied_Price);
    IndicatorParams adx_iparams(10, INDI_RVI);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_RVI(adx_params, adx_iparams, cparams), NULL, NULL);
    sparams.logger.SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.RVI_SignalBaseMethod, _params.RVI_SignalOpenMethod1, _params.RVI_SignalOpenMethod2,
                       _params.RVI_SignalCloseMethod1, _params.RVI_SignalCloseMethod2, _params.RVI_SignalOpenLevel,
                       _params.RVI_SignalCloseLevel);
    sparams.SetStops(_params.RVI_TrailingProfitMethod, _params.RVI_TrailingStopMethod);
    sparams.SetMaxSpread(_params.RVI_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_RVI(sparams, "RVI");
    return _strat;
  }

  /**
   * Check if RVI indicator is on buy or sell.
   *
   * @param
   *   _cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   _signal_method (int) - signal method to use by using bitwise AND operation
   *   _signal_level1 (double) - signal level to consider the signal
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    bool _result = false;
    /*
    double rvi_0 = ((Indi_RVI *) this.Data()).GetValue(0);
    double rvi_1 = ((Indi_RVI *) this.Data()).GetValue(1);
    double rvi_2 = ((Indi_RVI *) this.Data()).GetValue(2);
    */
    if (_signal_method == EMPTY) _signal_method = GetSignalBaseMethod();
    if (_signal_level1 == EMPTY) _signal_level1 = GetSignalLevel1();
    if (_signal_level2 == EMPTY) _signal_level2 = GetSignalLevel2();
    switch (_cmd) {
      /*
        //26. RVI
        //RECOMMENDED TO USE WITH A TREND INDICATOR
        //Buy: main line (green) crosses signal (red) upwards
        //Sell: main line (green) crosses signal (red) downwards
        if(iRVI(NULL,pirvi,pirviu,LINE_MAIN,1)<iRVI(NULL,pirvi,pirviu,LINE_SIGNAL,1)
        && iRVI(NULL,pirvi,pirviu,LINE_MAIN,0)>=iRVI(NULL,pirvi,pirviu,LINE_SIGNAL,0))
        {f26=1;}
        if(iRVI(NULL,pirvi,pirviu,LINE_MAIN,1)>iRVI(NULL,pirvi,pirviu,LINE_SIGNAL,1)
        && iRVI(NULL,pirvi,pirviu,LINE_MAIN,0)<=iRVI(NULL,pirvi,pirviu,LINE_SIGNAL,0))
        {f26=-1;}
      */
      case ORDER_TYPE_BUY:
        break;
      case ORDER_TYPE_SELL:
        break;
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    if (_signal_level == EMPTY) _signal_level = GetSignalCloseLevel();
    return SignalOpen(Order::NegateOrderType(_cmd), _signal_method, _signal_level);
  }
};
