# Flutter Feature Structure Template

## Use when

A cohesive product capability owns behavior, data access, or UI. Do not create a feature directory for a single generic helper.

```text
features/<feature>/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── use_cases/
├── data/
│   ├── data_sources/
│   ├── models/
│   ├── mappers/
│   └── repositories/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

Create only directories the feature needs. Dependencies point inward:

```text
presentation → domain ← data
```

## Checklist

- Feature responsibility and public surface are documented.
- Domain imports no Flutter or infrastructure package.
- Generated DTOs stay in `data`.
- Database and network calls stay behind repository/data-source boundaries.
- Cross-feature dependencies use approved contracts, not deep imports.
- Tests mirror behavior rather than directory structure mechanically.
