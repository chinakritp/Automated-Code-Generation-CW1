package q2.cp4n17;

import java.io.PrintWriter;
import java.io.FileNotFoundException;
import java.util.ArrayList;

import java.lang.Exception;

public aspect RefineCallGraph {

	String parent = "";
	
	ArrayList<String> nodes = new ArrayList<String>();
	ArrayList<String> edges = new ArrayList<String>();
	
	PrintWriter csvNodes;
	PrintWriter csvEdges;
	
	RefineCallGraph() throws FileNotFoundException {
		csvNodes = new PrintWriter("q2-nodes.csv");
		csvEdges = new PrintWriter("q2-edges.csv");
	}
	
	pointcut callGraph(): call(public int q2..*(int));
	pointcut executeGraph(): execution(public int q2..*(int));
	
	before(): callGraph() && withincode(public int q2..*(int)) {
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
	
	after() throwing(Exception e): executeGraph() {
		for(String edge : edges) {
			if(edge.contains("->"+thisJoinPoint.getSignature().toString())) {
				edges.remove(edge);
				return;
			}
		}
	}
	
	Object around(): executeGraph() {
		Object result = null;
	    try {
	    		if(!nodes.contains(thisJoinPoint.getSignature().toString())) {
				nodes.add(thisJoinPoint.getSignature().toString());
			}
			parent = thisJoinPoint.getSignature().toString();
	        result = proceed();
	    } catch (Exception e) {
	        System.out.println("Thrown an exception: " + e );
	    } finally {
	        parent = "";
	        return result;
	    }
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