protocol Graphable {
  associatedtype Element: Hashable
  var description: CustomStringConvertible { get }
  
  func createVertex(data: Element) -> Vertex<Element> 
  func add(_ type: EdgeType, from source: Vertex<Element>, to destination: Vertex<Element>)
  func edges(from source: Vertex<Element>) -> [Edge<Element>]? 
}

// Linked List

public struct LinkedList<T>: CustomStringConvertible {
  private var head: Node<T>?
  private var tail: Node<T>?

  public init() { }

  public var isEmpty: Bool {
    return head == nil
  }

  public var first: Node<T>? {
    return head
  }

  public mutating func append(_ value: T) {
    let newNode = Node(value: value)
    if let tailNode = tail {
      newNode.previous = tailNode
      tailNode.next = newNode
    } else {
      head = newNode
    }
    tail = newNode
  }

  public mutating func remove(_ node: Node<T>) -> T {
    let prev = node.previous
    let next = node.next

    if let prev = prev {
      prev.next = next
    } else {
      head = next
    }
    next?.previous = prev

    if next == nil {
      tail = prev
    }

    node.previous = nil
    node.next = nil

    return node.value
  }

  public var description: String {
    var text = "A ["
    var node = head

    while node != nil {
      text += "\(node!.value)"
      node = node!.next
      if node != nil { text += ", " }
    }
    return text + "]"
  }
}

public class Node<T> {
  public var value: T
  public var next: Node<T>?
  public var previous: Node<T>?

  public init(value: T) {
    self.value = value
  }
}


// Stack

extension Stack: CustomStringConvertible {
  var description: String {
    let stackElements = "\(array.reversed().description)"

    return stackElements 
  }
}

struct Stack<T: Hashable> {
  fileprivate var array: [T] = []

  var isEmpty: Bool {
    return array.isEmpty
  }

  var count: Int {
    return array.count
  }

  mutating func push(_ element: T) {
    array.append(element)
  }

  mutating func pop() -> T? {
    return array.popLast()
  }

  func peek() -> T? {
    return array.last
  }
}

// Queue

extension Queue: CustomStringConvertible {
  public var description: String {
    return list.description
  }
}

struct Queue<T: Hashable> {
  fileprivate var list = LinkedList<T>()

  public var isEmpty: Bool {
    return list.isEmpty
  }

  public mutating func enqueue(_ element: T) {
    list.append(element)
  }

  public mutating func dequeue() -> T? {
    guard !list.isEmpty, let element = list.first else { return nil }

    list.remove(element)

    return element.value
  }

  public func peek() -> T? {
    return list.first?.value
  }
}

// Vertex

extension Vertex: Hashable {
  public var hashValue: Int {
      return "\(data)".hashValue
  }
  
  static public func ==(lhs: Vertex, rhs: Vertex) -> Bool {
    return lhs.data == rhs.data
  }
}

extension Vertex: CustomStringConvertible {
  public var description: String {
    return "\(data)"
  }
}

public struct Vertex<T: Hashable> {
  var data: T
}

// Edges

extension Edge: Hashable {
  
  public var hashValue: Int {
      return "\(source)\(destination)".hashValue
  }
  
  static public func ==(lhs: Edge<T>, rhs: Edge<T>) -> Bool {
    return lhs.source == rhs.source &&
      lhs.destination == rhs.destination
  }
}

public enum EdgeType {
  case directed, undirected
}

public struct Edge<T: Hashable> {
  public var source: Vertex<T>
  public var destination: Vertex<T>
}

//AdjacencyList

extension AdjacencyList: Graphable {
  public typealias Element = T

  public var description: CustomStringConvertible {
    var result = ""
    for (vertex, edges) in adjacencyDict {
        var edgeString = ""
        for (index, edge) in edges.enumerated() {
        if index != edges.count - 1 {
            edgeString.append("\(edge.destination), ")
        } else {
            edgeString.append("\(edge.destination)")
        }
        }
        result.append("\(vertex) ---> [ \(edgeString) ] \n ")
    }
    return result
  }

  public func createVertex(data: Element) -> Vertex<Element> {
    let vertex = Vertex(data: data)
    
    if adjacencyDict[vertex] == nil {
        adjacencyDict[vertex] = []
    }

    return vertex
  }

  public func add(_ type: EdgeType, from source: Vertex<Element>, to destination: Vertex<Element>) {
    switch type {
    case .directed:
        addDirectedEdge(from: source, to: destination)
    case .undirected:
        addUndirectedEdge(vertices: (source, destination))
    }
  }

  public func edges(from source: Vertex<Element>) -> [Edge<Element>]? {
    return adjacencyDict[source]
  }
}

enum Visit<Element: Hashable> {
  case source
  case edge(Edge<Element>)
}

open class AdjacencyList<T: Hashable> {
  public var adjacencyDict : [Vertex<T>: [Edge<T>]] = [:]
  public init() {}

  class Busqueda{
     init(){}

     func depthFirstSearch(from start: Vertex<T>, to end: Vertex<T>, graph: AdjacencyList<T>) -> Int {
        var visited = Set<Vertex<T>>() 
        var stack = Stack<Vertex<T>>() 

        stack.push(start)
        visited.insert(start)

        outer: while let vertex = stack.peek(), vertex != end {
            // El vértice en el que estamos no tiene más vecinos por visitar, así que hacemos backtrack
            guard let neighbors = graph.edges(from: vertex), neighbors.count > 0 else {
                print("backtrack from \(vertex)")
                stack.pop()
                continue
            }
            
            // Para los vertices vecinos a vertices, si no han sido visitados, se visitan 
            for edge in neighbors {
                if !visited.contains(edge.destination) {
                  visited.insert(edge.destination)
                  stack.push(edge.destination)
                  print(stack.description)
                  continue outer
                }
            }
            
            print("backtrack from \(vertex)")
            stack.pop()
        }

        if (stack.count == 0){
            return -1
        }

        return stack.count
     }


     func breadthFirstSearch(from source: Vertex<T>, to destination: Vertex<T>, graph: AdjacencyList<T>) -> Int {

        var queue = Queue<Vertex<T>>()
        var visits : [Vertex<T> : Visit<T>] = [source: .source]
        queue.enqueue(source)

        while let visitedVertex = queue.dequeue() {

          // Si el ultimo vertice visitado es el destino, se reune el camino a seguir usando el 'diccionario' de visitas
          if visitedVertex == destination {
            var vertex = destination 
            var route: [Edge<T>] = []

            while let visit = visits[vertex],
            case .edge(let edge) = visit {

                route = [edge] + route
                vertex = edge.source

            }

            for edge in route {
              print("\(edge.source) -> \(edge.destination)")
            }

            return route.count + 1
          }
              
          // Si no es el vertice destino, considerar todos los vecinos posibles del vertice en cuestion
          let neighbourEdges = graph.edges(from: visitedVertex) ?? []
          for edge in neighbourEdges {
            if visits[edge.destination] == nil {
              queue.enqueue(edge.destination)
              visits[edge.destination] = .edge(edge)
            }
          }
        }
        return -1
      }
    }

  fileprivate func addDirectedEdge(from source: Vertex<Element>, to destination: Vertex<Element>) {
    let edge = Edge(source: source, destination: destination)
    adjacencyDict[source]?.append(edge)
  }

  fileprivate func addUndirectedEdge(vertices: (Vertex<Element>, Vertex<Element>)) {
    let (source, destination) = vertices
    addDirectedEdge(from: source, to: destination)
    addDirectedEdge(from: destination, to: source)
  }
}

let adjacencyList = AdjacencyList<Int>()

let v1 = adjacencyList.createVertex(data: 1)
let v2 = adjacencyList.createVertex(data: 2)
let v3 = adjacencyList.createVertex(data: 3)
let v4 = adjacencyList.createVertex(data: 4)
let v5 = adjacencyList.createVertex(data: 5)
let v6 = adjacencyList.createVertex(data: 6)

adjacencyList.add(.undirected, from: v1, to: v2)
adjacencyList.add(.undirected, from: v1, to: v5)
adjacencyList.add(.undirected, from: v2, to: v3)
adjacencyList.add(.undirected, from: v2, to: v4)
adjacencyList.add(.undirected, from: v4, to: v5)

//print(adjacencyList.description)

var p = AdjacencyList<Int>.Busqueda()
var s = p.depthFirstSearch(from: v1, to: v6, graph: adjacencyList)

print(s)