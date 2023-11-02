import java.util.Iterator;
import java.util.Map;

enum TravelState {
  RESET,
  SEEK_DESTINATION,
  NO_DESTINATION,
  TRAVELLING
};

enum DijkstraState {
  RESET,
  PARSING,
  GROWING
};


boolean Travels = true;
boolean Dijkstra = true;


int mapSize = 128;
Node[] nodeArr = new Node[mapSize];

class Dykestra {
  DijkstraState dijkstraState = DijkstraState.RESET;
  Node startNode;
  Node targetNode;
  int last_transition;
  int transitionTime = int(random(500)+1500);
  ArrayList<DijkstraEntry> paths;

  public Dykestra(Node startPoint, Node endPoint){
    this.startPoint = startPoint;
    this.endPoint = endPoint;
  }
  
  class DykestraEntry {
    float pathsum;
    ArrayList<Node> nodelist;
    
    public DykestraEntry (float pathsum, ArrayList<Node> nodelist) {
      this.pathsum = pathsum;
      this.nodelist = nodelist;
    }
  }


class Arrow { 
  Node start;
  Node end;
  
  public Arrow(Node start, Node end) {
    this.start = start;
    this.end = end;
  }
  
  void draw() {
    float P = 0.1;
    stroke(127);
    strokeWeight(0.2);
    PVector p = start.pos;
    PVector q = end.pos;
    line(p.x, p.y, p.z, q.x, q.y, q.z);
    PVector r = start.pos.copy();
    r.sub(end.pos);
    r.mult(P);
    PVector A = end.pos.copy();
    A.add(r);
    
    stroke(255,0,0,100);
    strokeWeight(0.5);
    line(q.x,q.y,q.z,A.x,A.y,A.z);
  }
}

class Node {
  PVector pos;
  HashMap<Node, Float> adjacency;
  public Node(PVector pos) {
    this.pos = pos;
    adjacency = new HashMap<Node, Float>();
  }
  void draw() {
    stroke(255);
    strokeWeight(int(1.75 * pow(adjacency.size(),0.25)));
    point(pos.x, pos.y, pos.z);
  }
}

class Traveller {
  Node travelNode, targetNode;
  TravelState state;
  int lastTransition;
  int transitionTime;
  
  public Traveller() {
    this.travelNode = this.targetNode = null;
    this.state = TravelState.RESET;
    this.transitionTime = int(random(500)) + 1500;
  }
  
  void travel(){  
    strokeWeight(3);
    switch (this.state) {
      case RESET:
        this.travelNode = nodeArr[int(random(mapSize))];
        transition(TravelState.SEEK_DESTINATION);
        break;
      case SEEK_DESTINATION:
        drawTravelNode(color(255,0,0));
        if (this.travelNode.adjacency.size() == 0) {
          transition(TravelState.NO_DESTINATION);
        } else {
          this.targetNode = (Node) this.travelNode.adjacency.keySet().toArray()[int(random(this.travelNode.adjacency.size()))];
          transition(TravelState.TRAVELLING);
        }
        break;
      case NO_DESTINATION:
        drawTravelNode(color(int(cos(millis()/100.0) * 255.0),0,0));
        if (millis() - this.lastTransition > transitionTime) {
          transition(TravelState.RESET);
        }
        break;
      case TRAVELLING:
        if (millis() - this.lastTransition > transitionTime) {
          this.travelNode = this.targetNode;
          transition(TravelState.SEEK_DESTINATION);
        } else {
          float pct = (float)(millis() - this.lastTransition) / transitionTime;
          float t = sin(pct * PI/2);
          PVector p = this.travelNode.pos.copy();
          PVector q = this.targetNode.pos.copy();
          PVector r = p.copy();
          r.lerp(q, t);
          strokeWeight(2);
          stroke(0,255,0);
          point(r.x, r.y, r.z);
        }
      break;
      }
  }
  void transition(TravelState new_state) {
     this.state = new_state;
     this.lastTransition = millis();
  }
  void drawTravelNode(color c) {
    stroke(c);
    point(this.travelNode.pos.x, this.travelNode.pos.y, this.travelNode.pos.z);
  }
}


float distance(Node p, Node q){
  PVector p_ = p.pos.copy();
  p_.sub(q.pos);
  return p_.mag();
}

void connect(){
  for (Node p : nodeArr){
    for (Node q : nodeArr){
      if (distance(p, q) < 50.0) {
        if (!q.adjacency.containsKey(p) && q != p){
          p.adjacency.put(q, 0.0);
          //nodeArr.add(new Arrow(p, q));
        }
      }
    }
  }
}


void setup(){
  size(1024, 1024, P3D);
  smooth(4);
  float D = width / 4.0;
  background(0);
  for(int i = 0; i < mapSize; i++){
    nodeArr[i] = new Node(new PVector(random(D) - D/2.0, random(D) - D/2.0, random(D) - D/2.0));
  }
  for (int i = 0; i < numTravellers; i++) {
    travellers[i] = new Traveller();
  }
  dijkstra();
}


boolean canTravelCheck(Node p, Node q){
  if(p == null){
    return false;
  }
  print(p.pos, q.pos);
  if(p == q){
    print("FOUND");
    return true;
  }    
  Iterator<Map.Entry<Node, Float>> iterator = p.adjacency.entrySet().iterator();
  while (iterator.hasNext()) {
    Map.Entry<Node, Float> entry = iterator.next();
    return canTravelCheck(entry.getKey(), q);
  }
  return false;
}




int numTravellers = 10;
Traveller[] travellers = new Traveller[numTravellers];

void draw(){

  background(0);
  connect();
  translate(width/2.0, width/2.0,0);
  rotateY(millis()/3000.0);
  scale(2.0);
  
  for (Node p : nodeArr){
    p.draw();
    Iterator<Map.Entry<Node, Float>> iterator = p.adjacency.entrySet().iterator();
    while (iterator.hasNext()) {
      Map.Entry<Node, Float> entry = iterator.next();
      Arrow arrow = new Arrow(p, entry.getKey());
      arrow.draw();
    }
  }
  if (Travels){
  for (Traveller t : travellers) {
    t.travel();
  }
  }
}
