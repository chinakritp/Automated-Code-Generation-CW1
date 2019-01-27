package q3.cp4n17;

import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;

public aspect Failuers {
	
	HashMap<String, Integer[]> failuer = new HashMap<String, Integer[]>();
	
	PrintWriter csvFailuers;
	
	Failuers() throws FileNotFoundException {
		csvFailuers = new PrintWriter("failures.csv");
	}
	
	after() throwing(Exception e): execution(public int q3..*(int)) {
	    System.out.println("Threw an exception: " + e + "Joinpoint: " + thisJoinPoint.getSignature().toString());
	    String sig = thisJoinPoint.getSignature().toString();
        if(failuer.get(sig) == null) {
        		failuer.put(sig, new Integer[2]);
        		failuer.get(sig)[0] = 1;
        		failuer.get(sig)[1] = 1;
		}else{
			int init = failuer.get(sig)[1];
			failuer.get(sig)[1] = init++;
		}
	}
	
	Object around(): execution(public int q3..*(int)) {
		Object result = null;
	    try {
	        result = proceed();
	        String sig = thisJoinPoint.getSignature().toString();
	        if(failuer.get(sig) == null) {
	        		failuer.put(sig, new Integer[2]);
	        		failuer.get(sig)[0] = 1;
	        		failuer.get(sig)[1] = 0;
			}else{
				int init = failuer.get(sig)[0];
				failuer.get(sig)[0] = init++;
			}
	    } catch (Exception e) {
	        System.out.println("Thrown an exception: " + e );
	    } finally {
	        return result;
	    }
	}
	
	after(): call(public int q3..*(int)) && !cflowbelow(call(public int q3..*(int))) {
		csvFailuers.write("Key, Frequency of Failures\r\n");
		for(HashMap.Entry<String, Integer[]> entry : failuer.entrySet()) {
			String key = entry.getKey();
			Integer[] value = entry.getValue();
			double freqFailuer = value[1] / value[0] * 100;
			csvFailuers.write(key + ", " + freqFailuer + "%\r\n");
		}
		csvFailuers.close();
		System.out.println("Created failuer files.");
	}
	
}
