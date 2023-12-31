{
  policy: {
    phases: {
      hot: {
        min_age: '0ms',
        actions: {
          rollover: {
            max_size: '50gb',
            max_age: '5d',
          },
        },
      },
      delete: {
        min_age: '30d',
        actions: {
          delete: {},
        },
      },
    },
  },
}
