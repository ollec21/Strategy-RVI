/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_RVI_Params_M5 : RVIParams {
  Indi_RVI_Params_M5() : RVIParams(indi_rvi_defaults, PERIOD_M5) {
    period = 32;
    shift = 0;
  }
} indi_rvi_m5;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_RVI_Params_M5 : StgParams {
  // Struct constructor.
  Stg_RVI_Params_M5() : StgParams(stg_rvi_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = (float)0;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = (float)0;
    price_stop_method = 0;
    price_stop_level = (float)2;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_rvi_m5;
