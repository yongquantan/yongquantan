---
title: "Working with Voice AI is Easy, Try This"
date: 2025-05-10
description: "A quick guide to working with voice AI"
categories:
  - AI
  - Voice
authors:
  - yongquantan
---

Getting started with Voice AI can be easy. It's important to start simple to progressively build an understanding of what happens under the hood. By doing so, we can build a solid foundation for more complex applications. In addition, starting simple and adding complexity slowly helps us compare and appreciate the delta between demo-land & deployments into production.

Let's explore the following:

1. Simple Speech-to-Text (STT)
2. STT + Structured Outputs (e.g. JSON, Pydantic)
3. Evals for Audio

For starters, let's keep it simple with a basic speech-to-text provider.

<!-- more -->

## The Case for Simple STT

Ideally you want a simple process that is:

1. Easy to execute locally
2. Easy to run as a self-contained unit
3. Easy to understand

The following is a simple script that does just that:

```python
import os

import openai
from dotenv import load_dotenv

load_dotenv()

openai.api_key = os.getenv("OPENAI_API_KEY")

with open("audio.mp3", "rb") as audio_file: #read binary file
  transcript: str = openai.audio.transcriptions.create(
      model="whisper-1",
      file=audio_file,
      response_format="text"
  )

  print(transcript)

  # > "So today I want to talk about the decision..."

# The following process happens:
# 1. Audio is uploaded to the provider
# 2. Provider processes the audio and returns a transcript
# 3. The transcript is returned to the client
```

A simple script like this can be compared with the actual audio file and vibe-checked. The goal is to have an appreciation of the output itself.

## Using Speech to Power Workflows

Unstructured data like text is, understandably, not sufficient for automating operations. This is where using structured outputs can help guide speech into specific downstream workflows that can be executed.

**The intuition here:** do we have a data schema in mind, that we'll extract from the audio? If so, we can use that to guide the transcription process.

For structured outputs , the [Instructor](https://python.useinstructor.com/) library is a good starting point.

```python
import os

import instructor
import openai
from dotenv import load_dotenv
from instructor.multimodal import Audio
from openai import OpenAI
from pydantic import BaseModel, Field

load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")

class AudioSnippet(BaseModel):
    title: str = Field(
        ..., description="Concise and descriptive title of the video"
    )
    transcript: str = Field(
        ..., description="Transcript of the video"
    )
    summary: str = Field(
        ..., description="A brief summary of the video's content"
    )
    speakers: list[str] = Field(
        ...,
        description="List of speakers in the video"
    )
    key_points: list[str] = Field(
        ...,
        description="List of key points in the video"
    )

client = instructor.from_openai(OpenAI())

response = client.chat.completions.create(
    model="gpt-4o-audio-preview",
    response_model=AudioSnippet,
    modalities=["text"],
    audio={"voice": "alloy", "format": "wav"},
    messages =[
        {
            "role": "user",
            "content": [
                "Extract the following information from the audio",
                Audio.from_path("local/audio.wav")
            ]
        }
    ]
)

print(response)
# > title='Title of video'
# > transcript='Transcript of the video'
# > summary='A brief summary of the video'
# > speakers=['Speaker 1', 'Speaker 2']
# > key_points=['Key point 1', 'Key point 2']

# 1. Define the schema
# 2. Perform transcription
# 3. Create structured outputs
```

To extend the schema further for downstream workflows, consider fields like `speaker`, `confidence`, `timestamps`, etc.

For instance, if we're transcribing a conversation between a doctor and a patient, we can use the `speaker` field to identify the speaker of each segment of the conversation. A downstream diagnosis can be generated, based only on the doctor's statements.

## Evals for Audio

Recently, I worked on transcribing long-form conversations with different accents. We had to experiment with different methods, from Simple STT to chunking the audio and manually relabelling transcriptions to align with the audio.

What made further improvements possible was to measure the performance of our upgrades and modifications with metrics, like Word Error Rate (WER).

!!! Note
    The main purpose of evals is to measure the performance of our models. Beyond vibe checks, it's important to understand the ROI of our dev work on the model's performance & reliability.

```python
import os

import openai
from jiwer import wer
from dotenv import load_dotenv

load_dotenv()

openai.api_key = os.getenv("OPENAI_API_KEY")

with open("audio.mp3", "rb") as audio_file:
    transcript: str = openai.audio.transcriptions.create(
        model="whisper-1",
        file=audio_file,
        response_format="text"
    )

# > reference = "So today I talked about the decision..."
# > transcript = "So today I want to talk about the decision..."

error = wer(reference, transcript)

print(error)
# > 0.1
```

If you're planning to work with industry-specific terms, using `wer` is a good start. You can also expand it to include Keyword-Error Rate (KER) to measure the performance of your model on specific keywords. This can be particularly helpful for domain-specific applications like (e.g. medical conversations, legal proceedings, etc).

## Conclusion

Working with Voice AI can seem daunting at first, so it's important to start with basic flows first and build up to more complexity. Structuring outputs & using evals can be a solid foundation for more advanced workflows, which I hope to cover in the next article.

The code used in this article can be found in my [Working with Voice](https://github.com/hermit46/working-with-voice) repo