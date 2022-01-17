import UIKit
import UniformTypeIdentifiers

public enum AsyncDocumentPicker {}

@available(iOS 14.0, *)
public extension AsyncDocumentPicker {
  @MainActor
  static func pickDocuments(
    forOpeningContentTypes contentTypes: [UTType],
    from hostingVC: UIViewController,
    animated flag: Bool
  ) async -> [URL]? {
    let docPickerVC = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
    let handler = DocumentPickerHandler()
    docPickerVC.delegate = handler

    hostingVC.present(docPickerVC, animated: flag, completion: nil)

    // https://stackoverflow.com/questions/69247093/generic-parameter-t-could-not-be-inferred-swift-5-5
    return await withCheckedContinuation({ (continuation: CheckedContinuation<[URL]?, Never>) in
      handler.urlsDidPick = { urls in
        continuation.resume(returning: urls)
      }
    })
  }
}

@MainActor
class DocumentPickerHandler: NSObject, UIDocumentPickerDelegate {
  var urlsDidPick: ((_ urls: [URL]?) -> Void)?

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    urlsDidPick?(urls)
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    urlsDidPick?(nil)
  }
}
