package com.prolog.knowledge;

import com.prolog.knowledge.generator.KnowledgeBaseGenerator;

import java.io.IOException;

/**
 * Transformer runner.
 */
public class KnowledgeGeneratorRunner {
    /**
     * Program entry point.
     */
    public static void main(String[] args) throws IOException {
        String inputFilename = "movies.csv";
        String outputFilename = "knowledge_base.pl";
        new KnowledgeBaseGenerator(inputFilename, outputFilename, true).run();
    }
}
