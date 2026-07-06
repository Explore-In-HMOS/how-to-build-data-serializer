import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { Logger } from '../utils/Logger';

/**
 * Entry ability. Loads the home page and exposes the ability context
 * so the local storage service can access wearable preferences.
 */
export default class EntryAbility extends UIAbility {
  onCreate(): void {
    Logger.info('EntryAbility', 'onCreate');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        Logger.error('EntryAbility', `loadContent failed: ${err.message}`);
        return;
      }
      Logger.info('EntryAbility', 'home page loaded');
    });
  }

  onDestroy(): void {
    Logger.info('EntryAbility', 'onDestroy');
  }
}
