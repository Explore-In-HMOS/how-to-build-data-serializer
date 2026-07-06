/**
 * Precise decimal arithmetic for health metrics.
 *
 * ArkTS has no native Decimal type, so this is a small local implementation
 * (the kind of clearly-documented abstraction the codelab spec asks for). A
 * value is stored as an integer mantissa plus a scale (number of decimal
 * places), so 312.45 is mantissa 31245 with scale 2. Arithmetic stays on
 * integers, which avoids the classic floating-point error where 0.1 + 0.2
 * yields 0.30000000000000004.
 *
 * The supported value range is intentionally modest: it is sized for wearable
 * health metrics, not arbitrary-precision math.
 */
class Decimal {
  private mantissa: number;
  private scale: number;

  private constructor(mantissa: number, scale: number) {
    this.mantissa = mantissa;
    this.scale = scale;
  }

  static fromString(text: string): Decimal {
    const trimmed: string = text.trim();
    const negative: boolean = trimmed.startsWith('-');
    const unsigned: string = negative ? trimmed.slice(1) : trimmed;
    const dot: number = unsigned.indexOf('.');
    if (dot < 0) {
      const whole: number = Number.parseInt(unsigned, 10);
      return new Decimal(negative ? -whole : whole, 0);
    }
    const intPart: string = unsigned.slice(0, dot);
    const fracPart: string = unsigned.slice(dot + 1);
    const digits: number = Number.parseInt(intPart + fracPart, 10);
    return new Decimal(negative ? -digits : digits, fracPart.length);
  }

  private static pow10(n: number): number {
    let result: number = 1;
    for (let i = 0; i < n; i++) {
      result = result * 10;
    }
    return result;
  }

  add(other: Decimal): Decimal {
    const scale: number = Math.max(this.scale, other.scale);
    const a: number = this.mantissa * Decimal.pow10(scale - this.scale);
    const b: number = other.mantissa * Decimal.pow10(scale - other.scale);
    return new Decimal(a + b, scale);
  }

  divide(other: Decimal, places: number): Decimal {
    const exponent: number = other.scale - this.scale + places;
    let numerator: number = this.mantissa;
    if (exponent >= 0) {
      numerator = numerator * Decimal.pow10(exponent);
    } else {
      numerator = numerator / Decimal.pow10(-exponent);
    }
    const quotient: number = Math.round(numerator / other.mantissa);
    return new Decimal(quotient, places);
  }

  toString(): string {
    const negative: boolean = this.mantissa < 0;
    let digits: string = Math.abs(this.mantissa).toString();
    if (this.scale === 0) {
      return (negative ? '-' : '') + digits;
    }
    while (digits.length <= this.scale) {
      digits = `0${digits}`;
    }
    const splitAt: number = digits.length - this.scale;
    const intPart: string = digits.slice(0, splitAt);
    let fracPart: string = digits.slice(splitAt);
    // Trim trailing zeros for a cleaner watch display.
    fracPart = fracPart.replace(/0+$/, '');
    const body: string = fracPart.length > 0 ? `${intPart}.${fracPart}` : intPart;
    return (negative ? '-' : '') + body;
  }
}

/**
 * Public helpers used by the pipeline. Inputs and outputs are strings so
 * decimal-sensitive values never touch JavaScript floating point.
 */
export class DecimalCalculator {
  static divide(a: string, b: string, places: number): string {
    return Decimal.fromString(a).divide(Decimal.fromString(b), places).toString();
  }

  /** Decimal result of 0.1 + 0.2. Returns the exact "0.3". */
  static precisionDemoDecimal(): string {
    return Decimal.fromString('0.1').add(Decimal.fromString('0.2')).toString();
  }

  /** Plain floating-point result of 0.1 + 0.2, shown for contrast. */
  static precisionDemoFloat(): string {
    return (0.1 + 0.2).toString();
  }
}
