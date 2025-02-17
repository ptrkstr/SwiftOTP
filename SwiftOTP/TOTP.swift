//
//  TOTP.swift
//  SwiftOTP
//
//  Created by Lachlan Bell on 14/1/18.
//  Copyright © 2018 Lachlan Bell. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
//  distribute, sublicense, create a derivative work, and/or sell copies of the
//  Software in any work that is designed, intended, or marketed for pedagogical or
//  instructional purposes related to programming, coding, application development,
//  or information technology.  Permission for such use, copying, modification,
//  merger, publication, distribution, sublicensing, creation of derivative works,
//  or sale is expressly withheld.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

/// Time-based one time password object
public struct TOTP {
	public let secret: Data
	public let digits: Int
	public let timeInterval: Int
	public let algorithm: OTPAlgorithm

	/// Initialise time-based one time password object
	/// - parameter secret: Secret key data
	/// - parameter digits: Number of digits for generated string in range 6...8, defaults to 6
	/// - parameter algorithm: The hashing algorithm to use of type OTPAlgorithm, defaults to SHA-1
	/// - precondition: digits *must* be between 6 and 8 inclusive
	public init?(secret: Data, digits: Int = 6, timeInterval: Int = 30, algorithm: OTPAlgorithm = .sha1) {
		self.secret = secret
		self.digits = digits
		self.timeInterval = timeInterval
		self.algorithm = algorithm

		guard validateDigits(digit: digits) else { return nil }
	}

	/// Generate one time password string from Date object
	/// - parameter time: Date object to generate password for
	/// - returns: One time password string, nil if `Date` doesn't pass precondition.
	/// - precondition: `time` must be a `Date` at or after Unix epoch (01 Jan 1970 00:00 UTC)
	public func generate(time: Date) -> String? {
		let secondsPast1970 = floor(time.timeIntervalSince1970)
		guard secondsPast1970 >= TimeInterval(UInt64.min) else { return nil }
		return generate(secondsPast1970: .init(secondsPast1970))
	}

	/// Generate one time password string from Unix time
	/// - parameter secondsPast1970: Time since Unix epoch (01 Jan 1970 00:00 UTC)
	/// - returns: One time password string, nil if error
	public func generate(secondsPast1970: UInt) -> String {
		let counterValue = UInt64(floor(Double(secondsPast1970) / Double(timeInterval)))
		return Generator.shared.generateOTP(secret: secret, algorithm: algorithm, counter: counterValue, digits: digits)
	}

	/// Check to see if digits value provided is in the range 6...8 (specified in RFC 4226)
	/// - parameter digit: Number of digits for generated string
	private func validateDigits(digit: Int) -> Bool{
		let validDigits = 6...8
		return validDigits.contains(digit)
	}
}
