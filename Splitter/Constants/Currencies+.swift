//
//  Currencies+.swift
//  Splitter
//
//  Created by Vincent C. on 10/1/23.
//

import Foundation

extension Currency {
    static let symbolsToExclude: Set<String> = [
        // based on https://www.unicode.org/charts/beta/nameslist/n_20A0.html
        "\u{0024}", // $     dollar sign
        "\u{00A2}", // ¢     cent sign
        "\u{00A3}", // £     pound sign
        "\u{00A4}", // ¤     currency sign
        "\u{00A5}", // ¥     yen sign
        "\u{0192}", // ƒ     latin small letter f with hook
        "\u{058F}", // ֏     armenian dram sign
        "\u{060B}", // ‎؋‎     afghani sign
        "\u{09F2}", // ৲     bengali rupee mark
        "\u{09F3}", // ৳     bengali rupee sign
        "\u{0AF1}", // ૱    gujarati rupee sign
        "\u{0BF9}", // ௹    tamil rupee sign
        "\u{0E3F}", // ฿    thai currency symbol baht
        "\u{17DB}", // ៛     khmer currency symbol riel
        "\u{2133}", // ℳ    script capital m
        "\u{5143}", // 元
        "\u{5186}", // 円
        "\u{5706}", // 圆
        "\u{5713}", // 圓
        "\u{FDFC}", // ‎﷼‎     rial sign
        "\u{1E2FF}",// 𞋿     wancho ngun sign
        "\u{20A1}", // ₡     COLON SIGN // Costa Rica, El Salvador
        "\u{20A2}", // ₢     CRUZEIRO SIGN // Brazil
        "\u{A798}", // Ꞙ    latin capital letter f with stroke
        "\u{00A3}", // £     pound sign
        "\u{20BA}", // ₺     turkish lira sign
        "\u{20A6}", // ₦     NAIRA SIGN // Nigeria
        "\u{20B1}", // ₱     peso sign
        "\u{20B9}", // ₹     indian rupee sign // ≈    0052 R 0073 s
        "\u{20A9}", // ₩     WON SIGN
        "\u{20AA}", // ₪     NEW SHEQEL SIGN
        "\u{20AB}", // ₫     DONG SIGN
        "\u{20AC}", // €     EURO SIGN
        "\u{20A0}", // ₠     euro-currency sign
        "\u{20AD}", // ₭     KIP SIGN // Laos
        "\u{20AE}", // ₮     TUGRIK SIGN // Mongolia
        "\u{20B1}", // ₱     PESO SIGN // Filipino peso sign
        "\u{20A7}", // ₧     peseta sign
        "\u{20B2}", // ₲     GUARANI SIGN //  Paraguay
        "\u{20B4}", // ₴     HRYVNIA SIGN // Ukraine
        "\u{20B5}", // ₵     CEDI SIGN // Ghana
        "\u{00A2}", // ¢     cent sign
        "\u{023B}", // Ȼ     latin capital letter c with stroke
        "\u{20B8}", // ₸     TENGE SIGN // Kazakhstan
        "\u{2351}", // ⍑     apl functional symbol up tack overbar
        "\u{2564}", // ╤     box drawings down single and horizontal double
        "\u{3012}", // 〒    postal mark
        "\u{20B9}", // ₹     INDIAN RUPEE SIGN // official rupee currency sign for India
        "\u{0930}", // र     devanagari letter ra
        "\u{2133}", // ℳ    script capital m
        "\u{20BC}", // ₼     MANAT SIGN // Azerbaijan
        "\u{20BD}", // ₽     RUBLE SIGN // Russia
        "\u{20BE}", // ₾     LARI SIGN // Georgia
        "\u{20BF}", // ₿     BITCOIN SIGN
        "\u{20C0}", // ⃀     SOM SIGN // Kyrgyzstan
    ]
}
