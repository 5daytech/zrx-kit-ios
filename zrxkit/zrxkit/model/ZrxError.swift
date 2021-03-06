import Foundation

enum ZrxError: Error {
  case emptyResponse
  case cannotCreateTransaction
  case encodeError(String)
}
