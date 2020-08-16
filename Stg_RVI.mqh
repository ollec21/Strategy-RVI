/**
 * @file
 * Implements RVI strategy based on the Relative Vigor Index indicator.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_RVI.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT float RVI_LotSize = 0;                        // Lot size
INPUT int RVI_SignalOpenMethod = 0;                 // Signal open method (0-
INPUT float RVI_SignalOpenLevel = 0.00000000;       // Signal open level
INPUT int RVI_SignalOpenFilterMethod = 0.00000000;  // Signal open filter method
INPUT int RVI_SignalOpenBoostMethod = 0.00000000;   // Signal open boost method
INPUT int RVI_SignalCloseMethod = 0;                // Signal close method (0-
INPUT float RVI_SignalCloseLevel = 0.00000000;      // Signal close level
INPUT int RVI_PriceLimitMethod = 0;                 // Price limit method
INPUT float RVI_PriceLimitLevel = 0;                // Price limit level
INPUT int RVI_TickFilterMethod = 0;                 // Tick filter method
INPUT float RVI_MaxSpread = 6.0;                    // Max spread to trade (pips)
INPUT int RVI_Shift = 2;                            // Shift
INPUT string __RVI_Indi_RVI_Parameters__ =
    "-- RVI strategy: RVI indicator params --";  // >>> RVI strategy: RVI indicator <<<
INPUT unsigned int Indi_RVI_Period = 10;         // Averaging period
INPUT ENUM_SIGNAL_LINE Indi_RVI_Mode = 0;        // Indicator line index.

// Structs.

// Defines struct with default user indicator values.
struct Indi_RVI_Params_Defaults : RVIParams {
  Indi_RVI_Params_Defaults() : RVIParams(::Indi_RVI_Period) {}
} indi_rvi_defaults;

// Defines struct to store indicator parameter values.
struct Indi_RVI_Params : public RVIParams {
  // Struct constructors.
  void Indi_RVI_Params(RVIParams &_params, ENUM_TIMEFRAMES _tf) : RVIParams(_params, _tf) {}
};

// Defines struct with default user strategy values.
struct Stg_RVI_Params_Defaults : StgParams {
  Stg_RVI_Params_Defaults()
      : StgParams(::RVI_SignalOpenMethod, ::RVI_SignalOpenFilterMethod, ::RVI_SignalOpenLevel,
                  ::RVI_SignalOpenBoostMethod, ::RVI_SignalCloseMethod, ::RVI_SignalCloseLevel, ::RVI_PriceLimitMethod,
                  ::RVI_PriceLimitLevel, ::RVI_TickFilterMethod, ::RVI_MaxSpread, ::RVI_Shift) {}
} stg_rvi_defaults;

// Struct to define strategy parameters to override.
struct Stg_RVI_Params : StgParams {
  Indi_RVI_Params iparams;
  StgParams sparams;

  // Struct constructors.
  Stg_RVI_Params(Indi_RVI_Params &_iparams, StgParams &_sparams)
      : iparams(indi_rvi_defaults, _iparams.tf), sparams(stg_rvi_defaults) {
    iparams = _iparams;
    sparams = _sparams;
  }
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_H8.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_RVI : public Strategy {
 public:
  Stg_RVI(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_RVI *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Indi_RVI_Params _indi_params(indi_rvi_defaults, _tf);
    StgParams _stg_params(stg_rvi_defaults);
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Indi_RVI_Params>(_indi_params, _tf, indi_rvi_m1, indi_rvi_m5, indi_rvi_m15, indi_rvi_m30,
                                     indi_rvi_h1, indi_rvi_h4, indi_rvi_h8);
      SetParamsByTf<StgParams>(_stg_params, _tf, stg_rvi_m1, stg_rvi_m5, stg_rvi_m15, stg_rvi_m30, stg_rvi_h1,
                               stg_rvi_h4, stg_rvi_h8);
    }
    // Initialize indicator.
    RVIParams rvi_params(_indi_params);
    _stg_params.SetIndicator(new Indi_RVI(_indi_params));
    // Initialize strategy parameters.
    _stg_params.GetLog().SetLevel(_log_level);
    _stg_params.SetMagicNo(_magic_no);
    _stg_params.SetTf(_tf, _Symbol);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_RVI(_stg_params, "RVI");
    _stg_params.SetStops(_strat, _strat);
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
          int _bar_count0 = (int)_level * (int)_indi.GetPeriod();
          _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count0))
                                   : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count0));
          break;
        }
        case 1: {
          int _bar_count1 = (int)_level * (int)_indi.GetPeriod() * 2;
          _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count1))
                                   : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count1));
          break;
        }
      }
      _result += _trail * _direction;
    }
    return (float)_result;
  }
};
