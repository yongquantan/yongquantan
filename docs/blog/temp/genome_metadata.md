---
title: "Accelerating Genome Research with Intelligent Metadata Management"
date: 2025-04-02
description: "Data Engineering starts with: creating enough value to enable adoption"
categories:
  - Biotech
  - Data 
authors:
  - yongquantan
---

## **How a Metadata Engine can reduce Time-to-Insight for Genomic Researchers**

!!! Disclaimer
    Metagenomics Research is highly specialized information. My understanding of the field may not be 100% accurate, and I may make statements based on personal experience or observations. I take full responsibility for any errors or omissions in this post.

As a data engineer in a microbiome research startup, we're always drowning in a sea of data. The gap between cutting-edge research & practical application is ever widening for a multitude of reasons pertaining to both the domain expertise & technology needed to drive progress. So it makes sense that we should invest our time & energy in ways to optimize our workflow.

In this article, I'm excited to share some thoughts on how teams can leverage metadata management to accelerate the discovery & insights of genomics research, with De Novo workflows.

<!-- more -->

!!! Terminology
    The term '*De Novo*' refers to methods where genome sequences are assembled from scratch, without relying on reference sequences. These help accelerate the discovery of novel genes & variants, which in turn can inform future research & development. The high computational requirements & specialized expertise needed to generate such data means they're often dispersed across a wide range of data stores, yet each are unique & critical to the research outcome.

## **TL;DR**

By developing an **automated metadata extraction and management system** for bioinformatics workflows, we can drastically reduce data preparation time, eliminate manual errors in data tracking, and enable faster, more accurate research insights across previously siloed genomic analyses. Genomic outputs that used to exist in siloed data stores are now accessible in a unified, searchable database that accelerates research insights & powers further bioinformatics & ML workflows.

Additionally, ensuring compliance to industry best practices like [NCBI](https://www.ncbi.nlm.nih.gov/), while non-trivial, can be fruitful in enabling collaboration with external partners.

## **The Bioinformatics Data Bottleneck**

In the past decade, the field has seen a rapid increase in the number of publications, with a corresponding increase in the volume of raw data. This is largely attributed to the improvements made in next-generation sequencing (NGS) technologies, which have allowed researchers to collect higher-resolution data faster. The most relevant of such NGS technologies is metagenomics, which uses a combination of DNA sequencing and other technologies to analyze microbial communities in the environment. This rapid increase in data volume has led to a significant increase in the time it takes to prepare the data for analysis, which can delay the time taken to extract insights.

Metagenomics research typically follows a sequence of:

1. Workflow Execution
2. Data Processing
3. Filtering for a subset of data based on metadata
4. Data Analysis
5. Insight Extraction

In most cases, performing Steps 2-4 typically requires a bioinformatics researcher to dig through siloed data stores, download the necessary metadata, & create custom scripts to manually curate the data. This process typically takes hours, days, or weeks, depending on the complexity of the data.

**The Bottom Line:** The process of deriving insights from genomic data typically takes hours, days, or weeks, depending on the complexity of the data.

## **What is a Metadata Engine?**

In summary, a metadata engine does six big things:

<!-- ![Genome Metadata Flow](./assets/genome_metadata_flow.jpg) -->

* Parses raw data in cloud object storages (S3, GCS, etc) into relevant metadata (e.g. FASTQ, CheckM2, EnrichM, etc)
* Enables batch and/or event-driven ingestion for entire research teams
* Manages metadata with complex relationships, in a structured database
* Provides search and discovery capabilities based on metadata fields
* Accelerates researchers & data scientists' pipeline or ML workflows
* Ingests outputs from workflows back into the metadata database, spurring further analysis

The metadata engine enables a **prosumer paradigm**, where bioinformatics researchers can become **both** consumers and producers of genomic metadata.

All of these tasks, when executed well, drastically reduces time-to-insight on genomic research, by bridging the gap between data processing & analysis.


## **How can a Metadata Engine help?**

<!-- Talk about how exactly it (1) allows batch & event-driven ingestion, (2) parses data from a wide range of sources (checkm2, quast, etc) and allows for addition of new fields as they are discovered, (3) ensures compliance to industry best practices like NCBI, (4) provides search & discovery capabilities, and (5) unify genomic metadata across different metrics with key identifiers. All of this, in the goal of accelerating research insights & further bioinformatics & ML workflows.  -->

### Lamba Processing Architecture

Our solution leverages a Lambda architecture with these key components:

1. Multi-source data ingestion: The system automatically detects new data from both event-driven buckets (real-time processing) and manual triggers (batch processing), supporting both automated workflows and legacy data integration.
2. Specialized parsers for bioinformatics formats: We developed parsers for genomic files (FASTA, FNA), taxonomic lineage data (CSV), pathway annotations (TSV), quality metrics, and contamination assessments - eliminating manual extraction.
3. Unified data model: All metadata is transformed into a consistent schema that preserves relationships between samples, genomes, taxonomies, and functional pathways.
4. Research-optimized queries: The database supports complex filtering based on taxonomic classification, pathway presence, genome quality metrics, and contamination levels - queries that previously required manual interrogation of multiple datasets.

### Database Schema

For the workflows that it is powering, the database schema is designed with these goals in mind:

1. Support complex relationships between genomic metadata (samples, genomes, taxonomies, functional pathways, quality metrics & contamination assessments).
2. Support relationships between longitudinal data (e.g. tracking the relationships of a given sample across different workflows).
3. Ensure scalability by designing for future growth.
4. Ensure data consistency across different metrics.
5. Ensure compliance to industry best practices like NCBI.
6. Ensuring ease of search & discovery for researchers with different levels of expertise.

<!-- ![DB Sample](./assets/db_sample.png) -->

<!-- ![DB Sample Schema](./assets/db_sample_schema.png) -->

## **Future-Proofing**

Software architectures should be designed to be future-proof, with the goal of being able to handle the ever-growing volume of data in the future. Thus, foundations built now should be able to handle the following scenarios without major re-design:

1. Handling new bioinformatics tools by adding new parsers
2. Ensuring compliance to industry best practices like NCBI
3. Assuring data consistency across different metrics
4. Supporting scalable growth with database backend
5. Automated tracking to create opportunities for ML to identify patterns across multiple studies

## **Conclusion**

In conclusion, as genomic research continues to accelerate, it is becoming increasingly important to keep track of the metadata associated with the ever-growing number of assembled genomes. This paper presents a unified metadata management system that streamlines the process of tracking and using metadata, while also providing a framework for future-proofing against the growth in complexity and volume of genomic data.
