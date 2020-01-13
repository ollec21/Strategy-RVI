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
INPUT unsigned int RVI_Period = 10;                             // Averaging period
INPUT ENUM_SIGNAL_LINE RVI_Mode = 0;                            // Indicator line index.
INPUT int RVI_Shift = 2;                                        // Shift
INPUT int RVI_SignalOpenMethod = 0;                             // Signal open method (0-
INPUT double RVI_SignalOpenLevel = 0.00000000;                  // Signal open level
INPUT int RVI_SignalCloseMethod = 0;                            // Signal close method (0-
INPUT double RVI_SignalCloseLevel = 0.00000000;                 // Signal close level
INPUT int RVI_PriceLimitMethod = 0;                             // Price limit method
INPUT double RVI_PriceLimitLevel = 0;                           // Price limit level
INPUT double RVI_MaxSpread = 6.0;                               // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_RVI_Params : Stg_Params {
  unsigned int RVI_Period;
  ENUM_SIGNAL_LINE RVI_Mode;
  int RVI_Shift;
  int RVI_SignalOpenMethod;
  double RVI_SignalOpenLevel;
  int RVI_SignalCloseMethod;
  double RVI_SignalCloseLevel;
  int RVI_PriceLimitMethod;
  double RVI_PriceLimitLevel;
  double RVI_MaxSpread;

  // Constructor: Set default param values.
  Stg_RVI_Params()
      : RVI_Period(::RVI_Period),
        RVI_Mode(::RVI_Mode),
        RVI_Shift(::RVI_Shift),
        RVI_SignalOpenMethod(::RVI_SignalOpenMethod),
        RVI_SignalOpenLevel(::RVI_SignalOpenLevel),
        RVI_SignalCloseMethod(::RVI_SignalCloseMethod),
        RVI_SignalCloseLevel(::RVI_SignalCloseLevel),
        RVI_PriceLimitMethod(::RVI_PriceLimitMethod),
        RVI_PriceLimitLevel(::RVI_PriceLimitLevel),
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
    RVI_Params rvi_params(_params.RVI_Period);
    IndicatorParams rvi_iparams(10, INDI_RVI);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_RVI(rvi_params, rvi_iparams, cparams), NULL, NULL);
    sparams.logger.SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.RVI_SignalOpenMethod, _params.RVI_SignalOpenLevel, _params.RVI_SignalCloseMethod,
                       _params.RVI_SignalCloseLevel);
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
   *   _method (int) - signal method to use by using bitwise AND operation
   *   _level (double) - signal level to consider the signal
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    bool _result = false;
    /*
    double rvi_0 = ((Indi_RVI *) this.Data()).GetValue(0);
    double rvi_1 = ((Indi_RVI *) this.Data()).GetValue(1);
    double rvi_2 = ((Indi_RVI *) this.Data()).GetValue(2);
    */
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
  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    return SignalOpen(Order::NegateOrderType(_cmd), _method, _level);
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  double PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_STG_PRICE_LIMIT_MODE _mode, int _method = 0, double _level = 0.0) {
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd) * (_mode == LIMIT_VALUE_STOP ? -1 : 1);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 0: {
        // @todo
      }
    }
    return _result;
  }
};
