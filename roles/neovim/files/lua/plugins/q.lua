return {
  {
    name = 'amazonq',
    url = 'https://github.com/awslabs/amazonq.nvim.git',
    opts = {
      ssoStartUrl="https://amzn.awsapps.com/start",
      inline_suggest = true,
      filetypes = {
          'amazonq', 'bash', 'java', 'python', 'typescript', 'javascript', 'csharp', 'ruby', 'kotlin', 'sh', 'sql', 'c',
          'cpp', 'go', 'rust', 'lua',
      },
    },
  },
}

