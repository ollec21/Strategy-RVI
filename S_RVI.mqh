//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

/**
 * @file
 * Implementation of RVI strategy based on the Relative Vigor Index indicator.
 *
 * @docs
 * - https://docs.mql4.com/indicators/iRVI
 * - https://www.mql5.com/en/docs/indicators/iRVI
 */

// Includes.
#include <EA31337-classes\Strategy.mqh>
#include <EA31337-classes\Strategies.mqh>

// User inputs.
#ifdef __input__ input #endif string __RVI_Parameters__ = "-- Settings for the Relative Vigor Index indicator --"; // >>> RVI <<<
#ifdef __input__ input #endif int RVI_Shift = 2; // Shift
#ifdef __input__ input #endif int RVI_Shift_Far = 0; // Shift Far
#ifdef __input__ input #endif double RVI_SignalLevel = 0.00000000; // Signal level
#ifdef __input__ input #endif int RVI_SignalMethod = 0; // Signal method for M1 (0-

class RVI: public Strategy {
protected:

  double rvi[H1][FINAL_ENUM_INDICATOR_INDEX][FINAL_SLINE_ENTRY];
  int       open_method = EMPTY;    // Open method.
  double    open_level  = 0.0;     // Open level.

    public:

  /**
   * Update indicator values.
   */
  bool Update(int tf = EMPTY) {
    // Calculates the Relative Strength Index indicator.
    rvi[index][CURR][MODE_MAIN]   = iRVI(symbol, tf, 10, MODE_MAIN, CURR);
    rvi[index][PREV][MODE_MAIN]   = iRVI(symbol, tf, 10, MODE_MAIN, PREV + RVI_Shift);
    rvi[index][FAR][MODE_MAIN]    = iRVI(symbol, tf, 10, MODE_MAIN, FAR + RVI_Shift + RVI_Shift_Far);
    rvi[index][CURR][MODE_SIGNAL] = iRVI(symbol, tf, 10, MODE_SIGNAL, CURR);
    rvi[index][PREV][MODE_SIGNAL] = iRVI(symbol, tf, 10, MODE_SIGNAL, PREV + RVI_Shift);
    rvi[index][FAR][MODE_SIGNAL]  = iRVI(symbol, tf, 10, MODE_SIGNAL, FAR + RVI_Shift + RVI_Shift_Far);
    success = (bool) rvi[index][CURR][MODE_MAIN];
  }

  /**
   * Checks whether signal is on buy or sell.
   *
   * @param
   *   cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   signal_method (int) - signal method to use by using bitwise AND operation
   *   signal_level (double) - signal level to consider the signal
   */
  bool Signal(int cmd, ENUM_TIMEFRAMES tf = PERIOD_M1, int signal_method = EMPTY, double signal_level = EMPTY) {
    bool result = FALSE; int period = Timeframe::TfToIndex(tf);
    UpdateIndicator(S_RVI, tf);
    if (signal_method == EMPTY) signal_method = GetStrategySignalMethod(S_RVI, tf, 0);
    if (signal_level  == EMPTY) signal_level  = GetStrategySignalLevel(S_RVI, tf, 20);
    switch (cmd) {
      /*
        //26. RVI
        //RECOMMENDED TO USE WITH A TREND INDICATOR
        //Buy: main line (green) crosses signal (red) upwards
        //Sell: main line (green) crosses signal (red) downwards
        if(iRVI(NULL,pirvi,pirviu,MODE_MAIN,1)<iRVI(NULL,pirvi,pirviu,MODE_SIGNAL,1)
        && iRVI(NULL,pirvi,pirviu,MODE_MAIN,0)>=iRVI(NULL,pirvi,pirviu,MODE_SIGNAL,0))
        {f26=1;}
        if(iRVI(NULL,pirvi,pirviu,MODE_MAIN,1)>iRVI(NULL,pirvi,pirviu,MODE_SIGNAL,1)
        && iRVI(NULL,pirvi,pirviu,MODE_MAIN,0)<=iRVI(NULL,pirvi,pirviu,MODE_SIGNAL,0))
        {f26=-1;}
      */
      case OP_BUY:
        break;
      case OP_SELL:
        break;
    }
    result &= signal_method <= 0 || Convert::ValueToOp(curr_trend) == cmd;
    return result;
  }
};
