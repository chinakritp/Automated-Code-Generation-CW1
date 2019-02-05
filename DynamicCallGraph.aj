package q1.cp4n17;

import java.io.PrintWriter;
import java.io.FileNotFoundException;
import java.util.ArrayList;

public aspect DynamicCallGraph {

	String parent = "";
	
	ArrayList<String> nodes = new ArrayList<String>();
	ArrayList<String> edges = new ArrayList<String>();
	
	PrintWriter csvNodes;
	PrintWriter csvEdges;
	
	DynamicCallGraph() throws FileNotFoundException {
		csvNodes = new PrintWriter("q1-nodes.csv");
		csvEdges = new PrintWriter("q1-edges.csv");
	}
	
	pointcut callGraph(): call(public int q1..*(int));
	
	before(): callGraph() && withincode(public int q1..*(int)) {
		int existing = 0;
		for(String edge : edges) {
			if(edge.contains(parent) && edge.contains(thisJoinPoint.getSignature().toString())) {
				existing = 1;
			}
		}
		if(parent != "" && existing == 0) {
			edges.add(parent + "->" + thisJoinPoint.getSignature().toString());
		}
	}
	
	Object around(): callGraph() {
		if(!nodes.contains(thisJoinPoint.getSignature().toString())) {
			nodes.add(thisJoinPoint.getSignature().toString());
		}
		parent = thisJoinPoint.getSignature().toString();
		Object result = proceed();
		parent = "";
		return result;
	}
	
	after(): callGraph() && !cflowbelow(callGraph()) {
		System.out.println("Nodes: "+nodes);
		System.out.println("Edges: "+edges);
		
		for(String node : nodes) {
			csvNodes.write(node + "\r\n");
		}
		csvNodes.close();
		
		for(String edge : edges) {
			csvEdges.write(edge + "\r\n");
		}
		csvEdges.close();
	}
	
}
