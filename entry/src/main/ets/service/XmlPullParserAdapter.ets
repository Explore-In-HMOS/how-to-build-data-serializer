import { xml } from '@kit.ArkTS';

/**
 * Result of a pull-parse pass: element text values keyed by tag name, plus
 * the attributes found on the document.
 */
export interface ParsedXml {
  elements: Map<string, string>;
  attributes: Map<string, string>;
}

/**
 * Low-level XML/XMI parsing layer.
 *
 * Wraps the official @kit.ArkTS xml.XmlPullParser. The parser walks the
 * document token by token; we track the current start tag and capture the
 * following text node, which is the standard pull-parsing pattern (read node
 * name, read attributes, read text).
 */
export class XmlPullParserAdapter {
  /** Convert an ASCII XML string into an ArrayBuffer for the pull parser. */
  private static toArrayBuffer(text: string): ArrayBuffer {
    const buffer: ArrayBuffer = new ArrayBuffer(text.length);
    const view: Uint8Array = new Uint8Array(buffer);
    for (let i = 0; i < text.length; i++) {
      view[i] = text.charCodeAt(i) & 0xff;
    }
    return buffer;
  }

  static parse(xmlString: string): ParsedXml {
    const elements: Map<string, string> = new Map<string, string>();
    const attributes: Map<string, string> = new Map<string, string>();

    const parser: xml.XmlPullParser =
      new xml.XmlPullParser(XmlPullParserAdapter.toArrayBuffer(xmlString), 'UTF-8');

    let currentTag: string = '';

    const options: xml.ParseOptions = {
      supportDoctype: false,
      ignoreNameSpace: true,
      tokenValueCallbackFunction: (eventType: xml.EventType, info: xml.ParseInfo): boolean => {
        if (eventType === xml.EventType.START_TAG) {
          currentTag = info.getName();
        } else if (eventType === xml.EventType.TEXT) {
          const text: string = info.getText().trim();
          if (currentTag.length > 0 && text.length > 0) {
            elements.set(currentTag, text);
          }
        } else if (eventType === xml.EventType.END_TAG) {
          currentTag = '';
        }
        return true;
      },
      attributeValueCallbackFunction: (name: string, value: string): boolean => {
        attributes.set(name, value);
        return true;
      }
    };

    parser.parseXml(options);
    return { elements, attributes };
  }
}
