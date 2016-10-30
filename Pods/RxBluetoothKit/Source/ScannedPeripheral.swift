// The MIT License (MIT)
//
// Copyright (c) 2016 Polidea
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import CoreBluetooth

/** Represents instance of scanned peripheral - containing it's advertisment data, rssi and peripheral itself.
    To perform further actions `peripheral` instance variable can be used ia. to maintain connection.
 */
public class ScannedPeripheral {

    /**
    `Peripheral` instance, that allows to perform further bluetooth actions.
    */
    public let peripheral: Peripheral

    /**
    Advertisement data of scanned peripheral
    */
    public let advertisementData: AdvertisementData

    /**
    Scanned peripheral's RSSI value.
    */
    public let rssi: NSNumber

    init(peripheral: Peripheral, advertisementData: AdvertisementData, rssi: NSNumber) {
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.rssi = rssi
    }
}
