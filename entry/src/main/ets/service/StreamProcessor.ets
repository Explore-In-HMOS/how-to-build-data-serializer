/**
 * Chunked stream processing (the "stream" concept).
 *
 * This is a small, clearly-documented local abstraction that models a
 * readable -> writable flow: the source is read in fixed-size chunks,
 * each chunk is processed, and the processed chunks are written back into a
 * single result. It demonstrates handling large input without loading and
 * transforming everything in one step, plus completion and error states.
 *
 * A trivial pass-through transform is used here; a real pipeline could clean
 * or reshape each chunk before writing it.
 */
export interface StreamReport {
  chunks: number;
  bytes: number;
  output: string;
}

export class StreamProcessor {
  static async readInChunks(source: string, chunkSize: number): Promise<StreamReport> {
    if (chunkSize <= 0) {
      throw new Error('chunkSize must be greater than zero');
    }

    let output: string = '';
    let chunks: number = 0;

    for (let offset = 0; offset < source.length; offset += chunkSize) {
      // Yield between chunks so the read behaves like an async stream and the
      // UI stays responsive on the watch.
      await Promise.resolve();
      const chunk: string = source.slice(offset, offset + chunkSize);
      output += StreamProcessor.transform(chunk);
      chunks++;
    }

    return { chunks, bytes: source.length, output };
  }

  /** Pass-through transform. Kept separate so the write step is explicit. */
  private static transform(chunk: string): string {
    return chunk;
  }
}
