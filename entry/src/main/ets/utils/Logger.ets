import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0001;

/**
 * Thin wrapper around hilog so the codelab logs with a single consistent tag.
 */
export class Logger {
  static info(tag: string, message: string): void {
    hilog.info(DOMAIN, tag, '%{public}s', message);
  }

  static error(tag: string, message: string): void {
    hilog.error(DOMAIN, tag, '%{public}s', message);
  }
}
