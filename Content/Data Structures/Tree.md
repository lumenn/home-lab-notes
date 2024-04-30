A tree structure is hierarchical data, in business world most common example would be a company hierarchy, but assuming that there is only one owner. Each employee would be a node, having a parent node with his own boss.

```mermaid
flowchart TD
    A --> E((Head of Sales))
        E --> E1((Salesman))
        E --> E2((Salesman))
        E --> E3((Salesman))
    A((Owner)) --> C((Head of IT))
        C --> C1((Developer))
        C --> C2((Developer))
        C --> C3((Developer))

```