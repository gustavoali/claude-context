---
title: "Classic Papers on Software Engineering as a Discipline"
papers:
  - title: "Prospects for an Engineering Discipline of Software"
    author: "Mary Shaw"
    institution: "Carnegie Mellon University"
    year: 1990
    publication: "IEEE Software, Vol. 7, No. 6, pp. 15-24"
    tech_report: "CMU/SEI-90-TR-020"
    url: "https://www.sei.cmu.edu/library/prospects-for-an-engineering-discipline-of-software/"
    alt_url: "http://www.cse.msu.edu/~cse435/Handouts/SE-Papers/Shaw-SE-IEEE-Computer90.pdf"
  - title: "Software Engineering Programs Are Not Computer Science Programs"
    author: "David Lorge Parnas"
    institution: "McMaster University"
    year: 1999
    publication: "IEEE Software, Vol. 16, No. 6, pp. 19-30 (Nov/Dec 1999)"
    originally: "Annals of Software Engineering, Vol. 6, pp. 19-37, Apr. 1999"
    url: "https://link.springer.com/article/10.1023/A:1018949113292"
    alt_url: "https://bioinfo.uib.es/~joemiro/semdoc/PlansEstudis/Bachelor_Masters_Curricula/DParnas.pdf"
date_summarized: 2026-03-19
topic: software engineering vs computer science / coding
relevance: foundational arguments for the AI-dev-transformation research
---

# Shaw & Parnas: Classic Papers on Software Engineering as a Discipline

## Paper 1: Mary Shaw - "Prospects for an Engineering Discipline of Software" (1990)

### Main Thesis

Software engineering in 1990 was not yet a true engineering discipline, but had the potential to become one. By studying the historical evolution of civil engineering and chemical engineering, Shaw proposed a maturation model that could predict the trajectory of software toward professional engineering status.

### The Maturation Model (Craft -> Commercial -> Professional Engineering)

Shaw's central contribution is a three-stage model for how engineering disciplines emerge:

**Stage 1 - Craft:** Problems are solved by talented amateurs using intuition and brute force. Progress is haphazard. Knowledge is transmitted casually. Production is for personal or local use, not for resale at scale. Software in the mid-1960s was at this stage: programming was a virtuoso activity, emphasis was on small programs, and knowledge about what worked was transmitted informally as folklore.

**Stage 2 - Commercial:** Skilled craftsmen use established procedures refined pragmatically. Management strategies emerge for controlling development. Economic concerns drive refinement of procedures and materials. Training is in mechanics, not theory. The problems of routine production stimulate the development of a supporting science. Shaw argued that most of 1990s software practice was at this stage, characterized by development methodologies, configuration management, quality assurance, and cost estimation techniques -- "software management" more than "software engineering."

**Stage 3 - Professional Engineering:** Educated professionals use analysis and theory grounded in science. Progress relies on science rather than trial and error. New applications are enabled through analysis, not just accumulated experience. Market segmentation by product variety becomes possible. This stage requires a mature scientific basis.

Shaw placed 1990 software as transitioning between Craft and Commercial, with only isolated examples (compiler construction, algorithms/data structures) reaching early Professional Engineering status.

### Key Arguments

1. **Engineering is defined by five properties:** Creating cost-effective solutions, to practical problems, by applying scientific knowledge, to building things, in the service of mankind. Software practice in 1990 failed on most of these criteria, particularly the systematic application of scientific knowledge.

2. **Routine vs. innovative design:** Engineering distinguishes between routine design (reusing established solutions from handbooks/references) and innovative design (novel solutions to unfamiliar problems). Most software was treated as innovative when it should have been routine. The field lacked the handbooks, reference materials, and codified designs that make routine engineering possible.

3. **The science-engineering feedback loop:** Good engineering generates problems for science; good science enables better engineering practice. In software, this loop existed (e.g., algorithms research enabling compiler construction) but was underdeveloped. Shaw noted it takes approximately 20 years from a scientific result to routine engineering practice.

4. **Five tasks for the profession to become a true engineering discipline:**
   - Understand the nature of expertise required (not just coding skill but domain knowledge, ~50,000 chunks of information, 10+ years to world-class proficiency)
   - Recognize different ways to get information (memory, reference, derivation) and invest in reference materials
   - Encourage routine practice through handbooks and reusable designs
   - Expect professional specializations (internal: reliability, real-time, scientific computing; external: application domains)
   - Improve the coupling between science and commercial practice

5. **Computer science education was inadequate for engineering:** CS programs emphasized fresh creation from scratch, not the use of reference materials, reusable designs, or systematic application of theory. This produced researchers, not engineers.

### Relevance to Modern Debate

Shaw's model is remarkably predictive of the 2020s situation:
- The field has progressed further into the Commercial stage (frameworks, CI/CD, established practices)
- Some areas have reached Professional Engineering (compiler construction, database systems, cryptographic implementations)
- But much of software development remains craft-like, especially in application development
- AI coding assistants could be seen as either accelerating the move to Professional Engineering (by codifying and making accessible routine designs) or as reinforcing the Craft stage (by making it easier to produce code without understanding the underlying science)
- Shaw's emphasis on reference materials and routine design anticipates exactly what LLMs provide: instant access to accumulated knowledge about how to solve common problems
- Her concern that CS education trains researchers rather than engineers remains relevant to the "vibe coding" debate: are we producing people who understand software, or people who can prompt an AI to produce it?

---

## Paper 2: David Parnas - "Software Engineering Programs Are Not Computer Science Programs" (1999)

### Main Thesis

Software engineering should be treated as a distinct engineering discipline -- a member of the set {Civil Engineering, Mechanical Engineering, Chemical Engineering, Electrical Engineering, Software Engineering} -- and NOT as a subfield of computer science. This is not academic taxonomy; the distinction demands fundamentally different educational programs, accreditation standards, and professional responsibilities.

### Key Arguments

1. **The Physics/EE analogy:** Just as electrical engineering emerged from physics when the field matured enough to support a professional engineering discipline, software engineering should emerge from computer science. Physics is to EE as computer science is to software engineering. The scientific basis is the same; the educational goals and career paths are different. Physicists primarily extend knowledge; EEs primarily build products. Similarly, computer scientists should extend knowledge about computation while software engineers build trustworthy software products.

2. **Software engineers are not just good programmers:** An engineer is a professional held responsible for producing products fit for use. This requires understanding the environment in which software operates, knowledge of other engineering domains, the ability to work in teams with other types of engineers, and responsibility for safety, reliability, and usability. "Software Engineer" as a euphemism for "programmer" reflects ignorance about the historical and legal meaning of "Engineer."

3. **Science education vs. engineering education -- fundamental differences:**
   - Scientists learn: what is true, how to confirm/refute models, how to extend knowledge
   - Engineers learn: what is true and useful, how to apply that knowledge, broader knowledge for complete products, and the design discipline required for professional responsibility
   - Scientists can be narrow but must be current; engineers must be broad but need only proven, reliable knowledge
   - Science programs offer freedom and specialization; engineering programs are rigid with a defined core body of knowledge
   - In science, theory and practice are often separated; in engineering, they must be integrated

4. **CS programs fail as engineering education because:**
   - They offer too much freedom (accreditation requires examining the "weakest path" through a program)
   - Theory and practice are disconnected (Denotational Semantics as "theoretical," Compiler Construction as "practical," with no integration)
   - "Practical" courses are organized around fads and buzzwords rather than fundamentals
   - Many courses teach specific systems/languages that will be obsolete before graduation
   - Students learn to work alone and develop from scratch, not to use established techniques and reference materials

5. **Accreditation is essential:** Engineering disciplines have rigid accreditation (ABET, CEAB) that ensures a core body of knowledge. CS has no corresponding standard -- Parnas could not identify "a single piece of knowledge or technique that is always taught in all CS programs." SE should leverage existing engineering accreditation frameworks rather than creating new ones.

6. **The proposed SE curriculum** includes four categories:
   - General engineering courses shared with all disciplines (chemistry, calculus, mechanics, economics)
   - Courses introducing other engineering areas (materials, control systems, thermodynamics, computer architecture)
   - Applied mathematics specific to SE (logic, discrete math, statistics -- all taught with software applications)
   - Software design courses (22 courses covering programming, design, algorithms, real-time systems, HCI, security, etc.)

   Notably absent: compilers and operating systems as standalone courses (graduates are unlikely to design those products). Also absent: Java, web technology, component orientation, frameworks -- "today's replacements for earlier fads."

7. **Education must focus on fundamentals that last 40 years:** Parnas draws from his own EE education where the RCA Tube Manual was useless and professors taught fundamental physics and mathematics instead of specific tube characteristics. The devices and technologies popular at any given moment will be of no interest in a decade.

8. **Staffing is the critical problem:** SE programs need teachers who know how to design real systems and are interested in building products. Most CS faculty, "even those who identify their area of interest as software engineering, are interested in abstractions and are reluctant to get involved in product design." Practical experience in producing software products should be valued alongside publication records.

### Relevance to Modern Debate

Parnas's arguments have become even more pointed in the AI era:

- **The programmer-vs-engineer distinction is now existential.** If AI can handle programming (the craft of writing code), then the value shifts entirely to engineering: understanding requirements, designing for safety and reliability, integrating with physical systems, taking professional responsibility. Parnas's 1999 argument that "software engineers are not just good programmers" anticipates exactly this shift.

- **Fundamentals over fads.** Parnas's insistence on teaching principles that last 40 years rather than current frameworks is validated by how quickly AI makes specific technology knowledge obsolete. The engineer who understands control theory, mathematical logic, and design principles can direct AI tools; the programmer who only knows React 19 is competing directly with the AI.

- **The accreditation question is unresolved 27 years later.** Software development still lacks the professional licensing and accountability that Parnas advocated. As AI-generated code enters safety-critical systems, the question of who takes professional responsibility becomes urgent.

- **"Nature abhors a vacuum" -- AI fills the gap.** Parnas noted that CS departments filled the software education vacuum because engineering faculties ignored software. Today, AI coding tools fill the gap left by inadequate engineering education. Developers without engineering fundamentals use AI to produce code they cannot fully evaluate.

- **The curriculum he proposed maps to what AI cannot replace.** Requirements analysis, system design, performance analysis, safety and reliability engineering, integration with physical systems -- these are precisely the activities that remain human responsibilities even as AI handles code generation.

---

## Cross-Cutting Themes Relevant to AI-Dev-Transformation Research

### 1. The Craft-to-Engineering Arc
Both Shaw and Parnas describe software as a field that aspires to engineering status but has not achieved it. AI tools present a paradox: they could either accelerate the transition to professional engineering (by automating the craft/commercial aspects and forcing practitioners to operate at a higher level of abstraction) or they could lock the field into a permanent craft stage (by making it possible to produce working software without understanding the underlying principles).

### 2. Knowledge Codification
Shaw emphasized that engineering disciplines codify knowledge into handbooks and reference materials. LLMs are arguably the ultimate codification mechanism -- they embody the accumulated patterns, solutions, and practices of the entire field. The question is whether practitioners using LLMs are "applying codified knowledge" (engineering) or "following instructions without understanding" (craft).

### 3. Professional Responsibility
Parnas's core concern -- that engineers must take responsibility for the fitness of their products -- becomes critical when code is AI-generated. If a developer prompts an AI to generate code for a safety-critical system, who is the engineer? The developer who cannot evaluate the output is not an engineer by Parnas's definition, regardless of their job title.

### 4. Education vs. Training
Both papers argue that education in fundamentals (which endure) matters more than training in current technologies (which expire). AI makes this distinction sharper: training in specific tools/frameworks is devalued faster than ever, while education in design principles, mathematical reasoning, and engineering judgment becomes more valuable.

### 5. The Two Career Paths
Parnas's distinction between scientists (who extend knowledge) and engineers (who build products) maps onto a modern triad: scientists who advance AI/CS, engineers who design systems using AI as a tool, and operators who use AI to produce code without deep understanding. The middle category -- engineers -- is what both Shaw and Parnas advocated for and what the field still largely lacks.
