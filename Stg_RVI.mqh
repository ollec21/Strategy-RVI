/**
 * @file
 * Implements RVI strategy based on the Relative Vigor Index indicator.
 */

// User input params.
INPUT unsigned int RVI_Period = 10;                 // Averaging period
INPUT ENUM_SIGNAL_LINE RVI_Mode = 0;                // Indicator line index.
INPUT int RVI_Shift = 2;                            // Shift
INPUT int RVI_SignalOpenMethod = 0;                 // Signal open method (0-
INPUT float RVI_SignalOpenLevel = 0.00000000;      // Signal open level
INPUT int RVI_SignalOpenFilterMethod = 0.00000000;  // Signal open filter method
INPUT int RVI_SignalOpenBoostMethod = 0.00000000;   // Signal open boost method
INPUT int RVI_SignalCloseMethod = 0;                // Signal close method (0-
INPUT float RVI_SignalCloseLevel = 0.00000000;     // Signal close level
INPUT int RVI_PriceLimitMethod = 0;                 // Price limit method
INPUT float RVI_PriceLimitLevel = 0;               // Price limit level
INPUT float RVI_MaxSpread = 6.0;                   // Max spread to trade (pips)

// Includes.
#include <EA31337-classes/Indicators/Indi_RVI.mqh>
#include <EA31337-classes/Strategy.mqh>

// Struct to define strategy parameters to override.
struct Stg_RVI_Params : StgParams {
  unsigned int RVI_Period;
  ENUM_SIGNAL_LINE RVI_Mode;
  int RVI_Shift;
  int RVI_SignalOpenMethod;
  double RVI_SignalOpenLevel;
  int RVI_SignalOpenFilterMethod;
  int RVI_SignalOpenBoostMethod;
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
        RVI_SignalOpenFilterMethod(::RVI_SignalOpenFilterMethod),
        RVI_SignalOpenBoostMethod(::RVI_SignalOpenBoostMethod),
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
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Stg_RVI_Params>(_params, _tf, stg_rvi_m1, stg_rvi_m5, stg_rvi_m15, stg_rvi_m30, stg_rvi_h1,
                                    stg_rvi_h4, stg_rvi_h4);
    }
    // Initialize strategy parameters.
    RVIParams rvi_params(_params.RVI_Period);
    rvi_params.SetTf(_tf);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_RVI(rvi_params), NULL, NULL);
    sparams.logger.Ptr().SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.RVI_SignalOpenMethod, _params.RVI_SignalOpenLevel, _params.RVI_SignalCloseMethod,
                       _params.RVI_SignalOpenFilterMethod, _params.RVI_SignalOpenBoostMethod,
                       _params.RVI_SignalCloseLevel);
    sparams.SetPriceLimits(_params.RVI_PriceLimitMethod, _params.RVI_PriceLimitLevel);
    sparams.SetMaxSpread(_params.RVI_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_RVI(sparams, "RVI");
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0) {
    Indi_RVI *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid() && _indi[PREV].IsValid() && _indi[PPREV].IsValid();
    bool _result = _is_valid;
    if (_is_valid) {
      switch (_cmd) {
        case ORDER_TYPE_BUY:
          _result = _indi[CURR].value[LINE_MAIN] > _indi[CURR].value[LINE_SIGNAL] + _level;
          // Buy: main line (green) crosses signal (red) upwards.
          if (METHOD(_method, 0)) _result &= _indi[PPREV].value[LINE_MAIN] < _indi[PPREV].value[LINE_SIGNAL];
          if (METHOD(_method, 1)) _result &= _indi[CURR].value[0] < _level;
          break;
        case ORDER_TYPE_SELL:
          _result = _indi[CURR].value[LINE_MAIN] < _indi[CURR].value[LINE_SIGNAL] - _level;
          // Sell: main line (green) crosses signal (red) downwards.
          if (METHOD(_method, 0)) _result &= _indi[PPREV].value[LINE_MAIN] > _indi[PPREV].value[LINE_SIGNAL];
          if (METHOD(_method, 1)) _result &= _indi[CURR].value[0] > _level;
          break;
      }
    }
    return _result;
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  float PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0) {
    Indi_RVI *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid() && _indi[PREV].IsValid() && _indi[PPREV].IsValid();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    if (_is_valid) {
      switch (_method) {
        case 0: {
          int _bar_count = (int)_level * (int)_indi.GetPeriod();
          _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count))
                                   : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count));
          break;
        }
        case 1: {
          int _bar_count = (int)_level * (int)_indi.GetPeriod() * 2;
          _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count))
                                   : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count));
          break;
        }
      }
      _result += _trail * _direction;
    }
    return _result;
  }
};
