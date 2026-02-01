---
title: "Use Cases for Voice Agents: What's Holding Us Back"
date: 2025-06-01
description: "A quick guide to working with voice AI, part 2"
categories:
  - AI
  - Voice
authors:
  - yongquantan
---

Long


## Performant STT

When handling long-running conversations OR live-streaming audio, new concerns emerge. To keep the problem space cogent, I'd break down the concerns into the following categories: **Latency**, **Context**, and **Enterprise Compatibility**.

!!! Note
    At the bottom, I'll write down a running list of problems we should acknowledge, but I'm explicitly not addressing & why.

**Latency**
- Real time performance becomes significantly important - we want our apps to react fluidly to user input. While 500ms is typical for human-to-human conversations, 800ms it a good target to aim for conversational AI applications.

**Context**
- Partial Transcriptions are helpful for LLM conversation history management & reducing the cost of storing data (for voice AI, one minute of speech audio as audio takes about 13x more tokens than the equivalent in text)
- Diarization is helpful for workflows that require speaker identification (e.g. doctors vs patients)

**Enterprise Compatibility**
- Currently, WebSocket

<!-- more -->

Evals become even more important when working with voice AI. While we can


Real, performant STT has a ton of rabbit holes to deal with:

- Audio Quality: Mid-audio jitters, partial transcriptions, echo cancellation, background noise suppression, and more problems need to be dealt with.
- Device Access: browser-based access to microphones & handling of permissions is non-standard & hacky
- Conversation Design: push-to-talk, long-form conversations, and more.
- Performance: Chunking, parallel processing, and more.
- Reliability: Error handling, retries, and more.
- Security: Authentication, E2E encryption, and more.
- Scalability: Horizontal scaling, load balancing, and more.

With that in mind, a couple principles apply:

- **Recoverability**: Handle errors and retries gracefully
- **Continuity**: Stream audio into smaller, manageable chunks for transcription
- **Persistence**: for long-form conversations of up to 30 mins
- **Browser/App Microphone Capture**

If you're not familiar with WebRTC, here's a simple diagram to show how peer-to-peer audio streaming works:

```
(Person 1) ↔ (Signaling Server) ↔ (SFU) ↔ (Signaling Server) ↔ (Person 2)
                                  ↓
                          (Speech-to-Text Service)
                                  ↓
                          (Transcripts + Storage)
```

Let's see what this looks like in implementation:

```python
load_dotenv(override=True)

class TranscriptionLogger(FrameProcessor):
    """Logs transcription frames."""
    async def process_frame(self, frame: Frame, direction: FrameDirection):
        await super().process_frame(frame, direction)

async def run_bot(webrtc_connection: SmallWebRTCConnection):
    """Runs a pipecat bot that transcribes audio from a microphone."""
    transport = SmallWebRTCTransport(
        webrtc_connection=webrtc_connection,
        params=TransportParams(
            audio_in_enabled=True,
            vad_analyzer=SileroVADAnalyzer(),
        ),
    )

    stt = OpenAISTTService(
        model="whisper-1",
        api_key=os.getenv("OPENAI_API_KEY"),
    )

    tl = TranscriptionLogger()

    logger.info("SmallWebRTCTransport created, waiting for audio...")

    # Pipeline: Transport -> STT -> Frame Logger -> Transcription Logger
    pipeline = Pipeline([
        transport.input(),
        stt,
        FrameLogger(),
        tl
    ])

    task = PipelineTask(pipeline)

    @transport.event_handler("on_client_disconnected")
    async def on_client_disconnected(transport, client):
        logger.info(f"Client disconnected: {client}")

    @transport.event_handler("on_client_closed")
    async def on_client_closed(transport, client):
        logger.info(f"Client closed connection: {client}")
        await task.cancel()

    runner = PipelineRunner(handle_sigint=False)

    await runner.run(task)

if __name__ == "__main__":
    from run import main

    main()
    # 1. Loads bot file
    # 2. Starts a Web Server with WebRTC endpoints
    # 3. Handles Application Lifecycle
    # 4. Logs Status

```

The full code can be found [here](https://github.com/yongquantan/working-with-voice)

<!-- ## Building out our intuition for real time performance

For longer audio files (>10 min), you'll realize that

- The process takes quite some time
- If the transcript screws up midway, you wouldn't know till the end
- The audio quality matters a lot: echos and background noises can easily derail the transcription
- You can't vibe check the accuracy of the output as easily

Those issues are often caused by the following:

- This code is processed line-by-line, rather than in chunks. That means:
  - First, the entire audio file is uploaded to the provider
  - Then the provider processes the audio in its entirety
  - Finally, the transcript is returned only after the entire process is complete
- Any external failure (e.g. loss of connection) that happens along the way will result in the entire transcription failing (no output)
- Any internal failure (e.g. Whisper is trained only on 30s chunks of audio) can cascade into a degradation of transcription

(Many thanks to Daily's primer on [Voice AI & Voice Agents](https://voiceaiandvoiceagents.com/#websockets-webrtc) )
 -->


<!-- Must use Screen Studio for this one. A voice to voice modality will be really cool. -->


<!-- 1. Realtime convo, 2. Saving of convo history, 3. Partial transcriptions, 4. Performance -->