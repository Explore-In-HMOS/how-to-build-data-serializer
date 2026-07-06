import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { HealthRecord } from '../model/HealthRecord';

/**
 * Local persistence for the last pipeline run, using the official
 * @kit.ArkData preferences store. No backend, cloud, or network is involved.
 *
 * Stores: last processed record, last serialized XMI, last status, last run
 * timestamp.
 */
export class LocalStorageService {
  private static readonly STORE_NAME: string = 'serializer_store';
  private static readonly KEY_RECORD: string = 'last_record';
  private static readonly KEY_XMI: string = 'last_xmi';
  private static readonly KEY_STATUS: string = 'last_status';
  private static readonly KEY_RUN_AT: string = 'last_run_at';

  private static async store(context: common.Context): Promise<preferences.Preferences> {
    const options: preferences.Options = { name: LocalStorageService.STORE_NAME };
    return await preferences.getPreferences(context, options);
  }

  /** Saves the run and returns the timestamp written. */
  static async save(
    context: common.Context,
    record: HealthRecord,
    xmi: string,
    status: string
  ): Promise<string> {
    const savedAt: string = new Date().toISOString();
    const prefs: preferences.Preferences = await LocalStorageService.store(context);
    await prefs.put(LocalStorageService.KEY_RECORD, JSON.stringify(record));
    await prefs.put(LocalStorageService.KEY_XMI, xmi);
    await prefs.put(LocalStorageService.KEY_STATUS, status);
    await prefs.put(LocalStorageService.KEY_RUN_AT, savedAt);
    await prefs.flush();
    return savedAt;
  }

  static async loadXmi(context: common.Context): Promise<string> {
    const prefs: preferences.Preferences = await LocalStorageService.store(context);
    return await prefs.get(LocalStorageService.KEY_XMI, '') as string;
  }
}
