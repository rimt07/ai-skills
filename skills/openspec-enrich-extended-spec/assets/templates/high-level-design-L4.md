# {Feature Name} — High-Level Design (L4)

| Field | Value |
| --- | --- |
| **Ticket** | {TICKET-ID} |
| **Service** | {service-name} |
| **Status** | Draft |
| **Author** | OCP Engineering |
| **Last Updated** | {YYYY-MM-DD} |

---

## Overview

<!-- 
PURPOSE: Summarize the architectural choices for this feature in 3-5 bullets.
GUIDELINES:
- State the chosen architecture option (if alternatives were evaluated)
- State the retry/resilience option (if applicable)
- State the architecture pattern (Hexagonal, CQRS, etc.)
- State the messaging technology choice
- Keep to 4-6 bullets max
-->

This document presents the high-level design for the {Feature Name} capability within the OCP {Service.Name} service. The design follows:

* **{Architecture Option}** — {brief description of the chosen option}
* **{Retry/Resilience Option}** — {brief description}
* **Hexagonal Architecture** — consistent with the {reference service} pattern
* **{Pattern}** — {brief description (e.g., CQRS via Ocp.Cqrs)}
* **{Technology Choice}** — {brief description (e.g., RabbitMQ .NET client — no NServiceBus)}

---

## Hexagonal Architecture View

<!-- 
PURPOSE: Show the complete hexagonal architecture with all layers.
GUIDELINES:
- Use flowchart LR for left-to-right data flow through layers
- Include ALL layers: External_Left → Adapters_In → Application_Logic → Domain → Ports_Out → Adapters_Out → External_Right
- Use subgraph for each layer
- Show component relationships with arrows
- Include ALL components that will be implemented
- Name components with their interface/class names
-->

```mermaid
flowchart LR
    subgraph External_Left[External Systems - Inbound]
        EXT_IN1[{Inbound System 1}]
    end

    subgraph Adapters_In[Adapters In]
        ADAPTER_IN1[{Inbound Adapter - type}]
    end

    subgraph Application_Logic[Application Logic]
        CMD[{Command/Query}]
        HANDLER[{Command/Query Handler}]
        PIPE_1[{Pipeline Step 1}]
        PIPE_2[{Pipeline Step 2}]
        PIPE_3[{Pipeline Step 3}]
        PIPE_4[{Pipeline Step 4}]
        PIPE_5[{Pipeline Step 5}]
        PIPE_6[{Pipeline Step 6}]
        STATUS_H1[{Status Handler 1 - interface}]
        STATUS_H2[{Status Handler 2 - interface}]
    end

    subgraph Domain[Domain]
        STRATEGY[{Strategy - interface}]
        MAPPER[{Domain Service 1}]
        GUARD[{Domain Service 2}]
    end

    subgraph Ports_Out[Ports Out]
        PORT1[{IPort1}]
        PORT2[{IPort2}]
        PORT3[{IPort3}]
    end

    subgraph Adapters_Out[Adapters Out]
        ADAPT1[{Adapter 1}]
        ADAPT2[{Adapter 2}]
        ADAPT3[{Adapter 3}]
    end

    subgraph External_Right[External Systems - Outbound]
        EXT_OUT1[({External Store})]
        EXT_OUT2[{External Service}]
        EXT_OUT3[{External Bus}]
    end

    EXT_IN1 -->|{protocol}| ADAPTER_IN1
    ADAPTER_IN1 --> CMD
    CMD --> HANDLER
    HANDLER --> PIPE_1 --> PIPE_2 --> PIPE_3 --> PIPE_4 --> PIPE_5 --> PIPE_6
    PIPE_4 --> STRATEGY
    STRATEGY --> MAPPER
    STRATEGY --> STATUS_H1
    STRATEGY --> STATUS_H2
    PIPE_3 --> GUARD
    STATUS_H1 --> PORT2
    STATUS_H2 --> PORT2
    PIPE_2 --> PORT1
    PIPE_5 --> PORT3
    PORT1 --> ADAPT1
    PORT2 --> ADAPT2
    PORT3 --> ADAPT3
    ADAPT1 --> EXT_OUT1
    ADAPT2 --> EXT_OUT2
    ADAPT3 --> EXT_OUT3
```

---

## Queue / Messaging Topology (if applicable)

<!-- 
PURPOSE: Show the messaging infrastructure layout.
GUIDELINES:
- Include: main queue, retry queue, DLQ, and any deferral/queue-up paths
- Show message flow direction
- Show TTL/DLX relationships
- Include external "black box" systems that receive deferred messages
- Use flowchart LR for left-to-right flow
-->

```mermaid
flowchart LR
    PRODUCER[{Producer}] -->|Publish message| MAIN[{Main Queue}]
    MAIN -->|Consume| CONSUMER[{Consumer}]
    CONSUMER -->|NACK + headers| RETRY[{Retry Queue - per-message TTL}]
    RETRY -->|DLX after TTL expires| MAIN
    CONSUMER -->|Max retries exceeded| DLQ[{Dead Letter Queue}]
    CONSUMER -->|{Deferral condition}| DEFER[{Deferral Target - black box}]
```

---

## Strategy Resolution Flow (if applicable)

<!-- 
PURPOSE: Show how inbound messages are routed to specific handlers.
GUIDELINES:
- Show extraction of routing fields from the message
- Show the resolution logic (strategy pattern)
- Show branching between DirectMap (simple) and UseHandler (complex)
- Show the outcome for each branch
- Use flowchart TD for top-down decision flow
-->

```mermaid
flowchart TD
    MSG[Inbound Message] --> EXTRACT[Extract routing fields: {field1}, {field2}, {field3}]
    EXTRACT --> RESOLVE[Pipeline resolves {IStrategy} by {routing field}]
    RESOLVE --> STRAT[{Strategy}.Resolve({field2}, {field3})]
    STRAT --> DM{DirectMap?}
    DM -->|Yes| CREATE[Create output from type + payload]
    DM -->|No - UseHandler| HDLR[Execute {IHandler}.HandleAsync]
    HDLR --> RESULT[HandlerResult]
    CREATE --> PUB[Publish to {target}]
    RESULT --> PUB
    PUB --> ACK[ACK + Cleanup]
```

---

## Retry and Exhaustion Flow (if applicable)

<!-- 
PURPOSE: Show what happens during retries and when thresholds are exceeded.
GUIDELINES:
- Show message redelivery from retry queue
- Show general retry threshold check (DLQ path)
- Show handler-specific threshold checks (e.g., enforcement timeout)
- Show all possible outcomes: success, degraded success, defer, retry, DLQ
- Include reason-code differentiation for external system failures
- Use flowchart TD for top-down decision flow
-->

```mermaid
flowchart TD
    REDELIVER[Message redelivered from Retry Queue] --> PIPE_CHECK{Pipeline: retry-count >= maxRetries?}
    PIPE_CHECK -->|Yes| DLQ[Route to DLQ]
    PIPE_CHECK -->|No| PIPELINE[Pipeline: steps execute normally]
    PIPELINE --> STRAT{Strategy resolves handler}
    STRAT -->|{Handler 1}| H1_CHECK{Handler: threshold exceeded?}
    H1_CHECK -->|Yes - {fallback ID}| FALLBACK[{Fallback behavior} - ACK]
    H1_CHECK -->|No| CALL1[Call {External System}]
    CALL1 -->|SUCCESS| SUCCESS[{Success behavior} - ACK]
    CALL1 -->|BUSINESS_FAILURE| BIZ_FAIL[{Business failure behavior} - ACK]
    CALL1 -->|{SUSTAINED_OUTAGE_REASON}| DEFER[Defer - ACK from main queue]
    CALL1 -->|{TRANSIENT_FAILURE}| RETRY1[Return HandlerResult.Retry]
    STRAT -->|{Handler 2}| CALL2[Call {External System}]
    CALL2 -->|SUCCESS| EMIT_TERM[{Success behavior} - ACK]
    CALL2 -->|{SUSTAINED_OUTAGE_REASON}| DEFER2[Defer - ACK]
    CALL2 -->|{TRANSIENT_FAILURE}| RETRY2[Return HandlerResult.Retry]
    STRAT -->|DirectMap| EMIT_SIMPLE[Create output - Publish - ACK]
    RETRY1 --> NACK[Pipeline: NACK to Retry Queue]
    RETRY2 --> NACK
```

---

## Components and Interfaces

<!-- 
PURPOSE: Catalog every component per architectural layer.
GUIDELINES:
- One table per layer (Adapters In, Application Logic, Domain, Ports Out, Adapters Out)
- Component column: bold name
- Type column: interface, class type, pattern name
- Responsibility column: ONE sentence max
- Include ALL components from the architecture diagram
-->

### Adapters In

| Component | Type | Responsibility |
| --- | --- | --- |
| **{Adapter Name}** | {Type (e.g., IHostedService)} | {One-sentence responsibility. Include: protocol, acknowledgment mode, dispatch target.} |

### Application Logic

| Component | Type | Responsibility |
| --- | --- | --- |
| **{Command/Query}** | {CQRS Command/Query} | {What data it carries (e.g., message reference ID)} |
| **{Handler}** | {Command/Query Handler} | {What it orchestrates (e.g., the processing pipeline)} |
| **{Pipeline Steps}** | {Pattern (e.g., Chain of Responsibility)} | {Fixed-order steps: list them. Include short-circuit and threshold behaviors.} |
| **{Status Handler 1}** | {Interface (e.g., IStatusHandler)} | {What it handles. What external calls it makes. What results it returns.} |
| **{Status Handler 2}** | {Interface} | {Same format as above.} |

### Domain

| Component | Type | Responsibility |
| --- | --- | --- |
| **{Strategy}** | {Interface (e.g., IChannelStrategy)} | {What it resolves and based on what inputs. Emphasize: pure business rules, no port dependencies.} |
| **{Domain Service 1}** | {Domain Service} | {What it maps/transforms} |
| **{Domain Service 2}** | {Domain Service} | {What it guards/validates, including key composition} |

### Ports Out

| Port | Responsibility |
| --- | --- |
| **{IPort1}** | {What operations it exposes. List: load, persist, cleanup, etc.} |
| **{IPort2}** | {What operations it exposes. Include return types (e.g., outcome enum with reason code).} |
| **{IPort3}** | {What operations it exposes. Include confirmation semantics.} |

### Adapters Out

| Adapter | Implements | External System | Key Behavior |
| --- | --- | --- | --- |
| **{Adapter 1}** | {IPort1} | {External system name + protocol} | {Key behavior notes (e.g., retry policy, connection pooling)} |
| **{Adapter 2}** | {IPort2} | {External system + protocol} | {Key behavior (e.g., resilience library, timeout config)} |
| **{Adapter 3}** | {IPort3} | {External system + protocol} | {Key behavior (e.g., publisher confirms, serialization)} |

---

## Strategy Resolution Table (if applicable)

<!-- 
PURPOSE: Complete mapping of inputs to resolution outcomes.
GUIDELINES:
- One row per unique (input combination) → outcome
- Columns: routing fields + Resolution type + Handler/Output name
- Resolution is either "DirectMap" (simple, no side effects) or "UseHandler" (complex, has side effects)
- Sort by input field values
-->

| {Field 1} | {Field 2} | Resolution | Handler / Output Type |
| --- | --- | --- | --- |
| {Value A} | {Qualifier} | DirectMap | {OutputEventType} |
| {Value B} | {Qualifier} | UseHandler | {HandlerClassName} |
| {Value C} | {Qualifier 1} | UseHandler | {HandlerClassName} |
| {Value C} | {Qualifier 2} | DirectMap | {OutputEventType} |

---

## Error Handling

<!-- 
PURPOSE: Complete failure matrix showing behavior at every failure point.
GUIDELINES:
- Cover ALL failure points end-to-end (persistence, external calls, publishing, poison messages)
- Show immediate retry behavior (Polly/resilience library level)
- Show broker-level retry behavior (NACK)
- Show exhaustion outcome (DLQ, fallback, defer)
- Differentiate by failure reason when applicable
- Include constraint notes (e.g., enforcementMaxRetries < generalMaxRetries)
-->

| Failure Point | Immediate Retry (Polly) | Broker Retry (NACK) | Exhaustion Outcome |
| --- | --- | --- | --- |
| {Persistence} unreachable | {N} fast retries | Yes (NACK to Retry Queue) | DLQ after {maxRetries} |
| {External System} transient {failure type} | {N} fast retries | Yes (NACK with headers) | {Fallback behavior} after {threshold} |
| {External System} {SUSTAINED_REASON_1} | No retry | No retry | Defer to {deferral target}, ACK |
| {External System} {SUSTAINED_REASON_2} | No retry | No retry | Defer to {deferral target}, ACK |
| {External System} BUSINESS_FAILURE | No retry | No retry | {Degraded behavior} |
| {Publisher} failure | {N} fast retries | Yes (NACK to Retry Queue) | DLQ after {maxRetries} |
| Unrecognized {input} (poison) | No retry | No retry | Immediate reject to DLQ |

**Constraint:** {handler-specific threshold} < {general threshold}

---

## Key Design Decisions

<!-- 
PURPOSE: Document every significant design choice with rationale.
GUIDELINES:
- One row per decision
- Decision column: WHAT was decided (category)
- Choice column: WHICH option was chosen (name/description)
- Rationale column: WHY this option (benefits, trade-offs, rejected alternatives)
- Include decisions about: architecture, retry, routing, integration, state, locking, naming, DLQ, etc.
-->

| Decision | Choice | Rationale |
| --- | --- | --- |
| Architecture pattern | {Option chosen}: {brief description} | {Why — benefits, trade-offs} |
| Retry mechanism | {Option chosen}: {brief description} | {Why — restart-safe, observable, etc.} |
| Strategy inputs | {Fields used for routing} | {Why — vendor-agnostic, supports same-input-different-behavior} |
| External calls | {Inline / Async / Fire-and-forget} | {Why — consistency, expandability} |
| State management | {None / Event-sourced / DB-backed} | {Why — deferred to where, simplicity} |
| {Sustained outage handling} | {Route to deferral, ACK} | {Why — not retry, different mechanism} |
| DLQ management | {Strategy for Phase 1} | {Why — build more when justified} |
| Locking | {None / Optimistic / Distributed} | {Why — ordering + idempotency, no deadlocks} |
| {Component naming} | {Convention chosen} | {Why — explicit ownership, clarity} |

---

## Technology Stack

<!-- 
PURPOSE: Complete technology inventory per architectural layer.
GUIDELINES:
- One row per layer/concern
- Include: runtime version, libraries, messaging tech, database, resilience, observability, infrastructure, architecture
- Use specific version numbers where applicable
-->

| Layer | Technology |
| --- | --- |
| Runtime | {.NET version, hosting model} |
| CQRS | {Library name} |
| Messaging (internal) | {Technology + client library} |
| Messaging (outbound) | {Technology + confirms/guarantees} |
| Database | {Technology (compatibility note)} |
| HTTP resilience | {Library (underlying framework)} |
| Observability | {Logging library, format, tracing, APM} |
| Infrastructure | {Container, orchestrator, cloud provider} |
| Architecture | {Pattern names} |

---

## Open Questions (if any)

<!-- 
PURPOSE: Track unresolved design questions with ownership.
GUIDELINES:
- Number sequentially
- Include impact assessment (what's blocked if unresolved)
- Assign an owner
- Remove this section if no open questions remain
-->

| # | Question | Impact | Owner |
| --- | --- | --- | --- |
| 1 | {Unresolved question} | {What's blocked or degraded} | {Team/Person} |

---

## References

<!-- 
PURPOSE: Link to all related Confluence pages, specs, and reviews.
GUIDELINES:
- Include: Requirements L4, Solution Reviews, Architecture References, Related Specs
- Use full Confluence URLs with descriptive titles
- Group logically (requirements, reviews, architecture, related features)
-->

* [{Feature Name} — Requirements (L4)]({confluence-url})
* [{Solution Review — Topic 1}]({confluence-url})
* [{Solution Review — Topic 2}]({confluence-url})
* [{Solution Review — Topic 3}]({confluence-url})
* [{Architecture Reference}]({confluence-url})
* [{Related Feature Spec}]({confluence-url})
