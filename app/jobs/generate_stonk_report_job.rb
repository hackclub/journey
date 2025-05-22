require "json"
require "openai"

class GenerateStonkReportJob < ApplicationJob
  queue_as :default

  def perform
    report_data = Stonk.report.to_s

    OpenAI.configure { |c| c.access_token = ENV.fetch("OPENAI_KEY") }
    client = OpenAI::Client.new(request_timeout: 60 * 5, log_errors: true)

    # response = client.responses.create(
    #   parameters: {
    #     model: "o3",
    #     reasoning: { effort: "high" },
    #     messages: [
    #       { role: "system", content: system_msg },
    #       { role: "user",   content: user_msg }
    #     ],
    #   }
    # )
    response = client.responses.create(parameters: {
      "model": "o3",
      "input": [
        {
          "role": "developer",
          "content": [
            {
              "type": "input_text",
              "text": "Write a 250-to-300-word end-of-day market report (UTC) covering the last 24 hours, using a professional, objective, Bloomberg-style perspective.\n\nEnsure the report adheres to the following JSON schema guidelines:\n- Outer keys: `title`, `description`, `category`, `is_shipped`, `rating`, `project_created_at`\n- Inner keys: Day bucket (0 = last 24h, 1 = 24–48h, etc.)\n- Inner values: Number of Stonk investments during that day for that project, not cumulative.\n\nInclude detailed analysis:\n- Rank projects by today's (bucket 0) totals and highlight the top 3 movers.\n- Summarize the overall market tone as bullish, bearish, or mixed, and discuss notable sector flows.\n- Reference data from yesterday (bucket 1) where useful for illustrating percentage changes.\n- Conclude with a one-sentence market outlook.\n\n# Steps\n\n1. Analyze today's (day bucket 0) stocks investment data to identify the top three projects by totals.\n2. Compare today's (bucket 0) data with yesterday's (bucket 1) to articulate percentage changes and trends.\n3. Summarize the overall market tone and describe significant sector movements.\n4. Draft the report with a coherent flow, stating key findings and future insights.\n\n# Output Format\n\nThe report should be a coherent narrative of 250 to 300 words as HTML. Use professional financial language and a third-person point of view. Conclude with a one-sentence market outlook.\n\n# Notes\n\n- Ensure all analysis and narrative are objective and data-driven.\n- Use financial terminology and professional language suitable for a market analysis audience.\n- Avoid speculative language unless backed by data trends."
            }
          ]
        },
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": report_data
            }
          ]
        }
      ],
      "text": {
        "format": {
          "type": "text"
        }
      },
      "reasoning": {
        "effort": "high"
      },
      "tools": [],
      "store": false
    })

    report_text = response.dig("output", 1, "content", 0, "text").strip
    DailyStonkReport.find_or_initialize_by(date: Date.current).update!(report: report_text)
  end
end
