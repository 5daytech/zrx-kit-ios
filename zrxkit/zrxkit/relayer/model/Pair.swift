import Foundation

public class Pair<F,S> {
  public let first: F
  public let second: S
  
  public init(first: F, second: S) {
    self.first = first
    self.second = second
  }
}
