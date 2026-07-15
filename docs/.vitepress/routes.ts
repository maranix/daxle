export const Routes = {
  gettingStarted: {
    introduction: {
      text: 'Introduction',
      link: '/getting-started/introduction',
    },
    installation: {
      text: 'Installation',
      link: '/getting-started/installation',
    },
    quickStart: {
      text: 'Quick Start',
      link: '/getting-started/quick-start',
    },
  },
  coreTypes: {
    unit: {
      text: 'Unit',
      link: '/core-types/unit',
    },
    option: {
      text: 'Option',
      link: '/core-types/option',
    },
    either: {
      text: 'Either',
      link: '/core-types/either',
    },
    task: {
      text: 'Task',
      link: '/core-types/task',
    },
    taskEither: {
      text: 'TaskEither',
      link: '/core-types/task-either',
    },
  },
  utilities: {
    futureGroup: {
      text: 'FutureGroup',
      link: '/utilities/future-group'
    },
    asyncCache: {
      text: 'AsyncCache',
      link: '/utilities/async-cache'
    },
    asyncMemoizer: {
      text: 'AsyncMemoizer',
      link: '/utilities/async-memoizer'
    },
    streamZip: {
      text: 'StreamZip',
      link: '/utilities/stream-zip'
    },
    streamGroup: {
      text: 'StreamGroup',
      link: '/utilities/stream-group'
    },
    streamQueue: {
      text: 'StreamQueue',
      link: '/utilities/stream-queue'
    },
    streamSplitter: {
      text: 'StreamSplitter',
      link: '/utilities/stream-splitter'
    },
  },
  guides: {
    errorHandling: {
      text: 'Error Handling',
      link: '/guides/error-handling',
    },
    asyncProgramming: {
      text: 'Asynchronous Programming',
      link: '/guides/async-programming',
    },
    functionalComposition: {
      text: 'Functional Composition',
      link: '/guides/functional-composition',
    },
    bestPractices: {
      text: 'Best Practices',
      link: '/guides/best-practices',
    },
  },
  cookbooks: {
    parsingAndValidation: {
      text: 'Parsing and Validation',
      link: '/cookbook/parsing-and-validation',
    },
    workingWithOptionalValues: {
      text: 'Working with Optional Values',
      link: '/cookbook/working-with-optional-values',
    },
    buildingAsynchronousPipelines: {
      text: 'Building Asynchronous Pipelines',
      link: '/cookbook/building-asynchronous-pipelines',
    },
    errorRecovery: {
      text: 'Error Recovery',
      link: '/cookbook/error-recovery',
    },
    dataTransformation: {
      text: 'Data Transformation',
      link: '/cookbook/data-transformation',
    },
  },
} as const;
