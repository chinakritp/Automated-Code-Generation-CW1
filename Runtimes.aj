package q3.cp4n17;

import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;

public aspect Runtimes {
	
	HashMap<String, ArrayList<Double>> runtime = new HashMap<String, ArrayList<Double>>();
	
	PrintWriter csvRuntimes;
	
	Runtimes() throws FileNotFoundException {
		csvRuntimes = new PrintWriter("runtimes.csv");
	}
	
	Object around(): execution(* q3..*(*)) {
		Object result = null;
	    try {
	    		long start = System.nanoTime();
	        result = proceed();
	        long end = System.nanoTime();
	        double duration = (end - start) / 1000000;
	        String sig = thisJoinPoint.getSignature().toString();
	        if(runtime.get(sig) == null) {
        			runtime.put(sig, new ArrayList<Double>());
	        }
	        runtime.get(sig).add(duration);
	    } catch (Exception e) {
	        System.out.println("Thrown an exception: " + e );
	    } finally {
	        return result;
	    }
	}
	
	after(): call(* q3..*(*)) && !cflowbelow(call(* q3..*(*))) {
		csvRuntimes.write("Key, Average, Standard deviation\r\n");
		for(HashMap.Entry<String, ArrayList<Double>> entry : runtime.entrySet()) {
			String key = entry.getKey();
			ArrayList<Double> value = entry.getValue();
			double sum = 0;
			double sqrd = 0;
			double size = value.size();
			for(double duration : value) {
				sum += duration;
			}
			double mean = sum / size;
			for(double duration : value) {
				double x = duration - mean;
				sqrd += x * x;
			}
			double variance = sqrd/(size - 1);
			double sd = Math.sqrt(variance);
			if(Double.isNaN(sd)) {
				sd = 0;
			}
			
			csvRuntimes.write(key + ", " + mean + ", " + sd + "\r\n");
		}
		csvRuntimes.close();
		System.out.println("Created runtime files.");
	}
	
}
