package com.prolog;

import java.io.File;
import java.util.Map;

import org.jpl7.Query;
import org.jpl7.Term;

public class PrologQueryExecutor {

	private File prologFile;

	public PrologQueryExecutor(File prologFile) {
		this.prologFile = prologFile;
	}

	public boolean consultFile() {
		String consultFile = "consult('" + prologFile + "')";
		return Query.hasSolution(consultFile);
	}

	public Map<String, Term> executeQuery(String query) {
		Map<String, Term> terms = Query.oneSolution(query);
		return terms;
	}
}
