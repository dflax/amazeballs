//
//  AmazeballsWatchWidget.swift
//  AmazeballsWatchWidget
//
//  Created by Daniel Flax on 1/18/26.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct AmazeballsProvider: TimelineProvider {
    func placeholder(in context: Context) -> AmazeballsEntry {
        AmazeballsEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (AmazeballsEntry) -> ()) {
        let entry = AmazeballsEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Complication doesn't need to update - it's just a launcher
        // Create a single entry that refreshes daily
        let currentDate = Date()
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        
        let entry = AmazeballsEntry(date: currentDate)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

// MARK: - Timeline Entry

struct AmazeballsEntry: TimelineEntry {
    let date: Date
}

// MARK: - Complication Views

struct AmazeballsComplicationView: View {
    var entry: AmazeballsProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView
        case .accessoryRectangular:
            rectangularView
        case .accessoryInline:
            inlineView
        case .accessoryCorner:
            cornerView
        default:
            circularView
        }
    }
    
    // MARK: - Circular Complication
    
	private var circularView: some View {
		Image("ball_icon")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: 32, height: 32)
	}

	// MARK: - Rectangular Complication

	private var rectangularView: some View {
		HStack(spacing: 8) {
			Image("ball_icon")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 32, height: 32)
			
			VStack(alignment: .leading, spacing: 2) {
				Text("Amazeballs")
					.font(.system(size: 14, weight: .bold))
				Text("Tap to play")
					.font(.system(size: 11, weight: .regular))
					.foregroundStyle(.secondary)
			}
			Spacer()
		}
        .padding(.horizontal, 4)
    }

	// MARK: - Inline Complication
    private var inlineView: some View {
		Image("ball_icon")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: 24, height: 24)
	}

	// MARK: - Corner Complication
	private var cornerView: some View {
		Image("ball_icon")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: 24, height: 24)
	}
}

// MARK: - Widget Configuration

struct AmazeballsWatchWidget: Widget {
    let kind: String = "AmazeballsWatchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AmazeballsProvider()) { entry in
            AmazeballsComplicationView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Amazeballs")
        .description("Launch Amazeballs physics sandbox")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCorner
        ])
    }
}

// MARK: - Previews

#Preview("Circular", as: .accessoryCircular) {
    AmazeballsWatchWidget()
} timeline: {
    AmazeballsEntry(date: .now)
}
#Preview("Rectangular", as: .accessoryRectangular) {
    AmazeballsWatchWidget()
} timeline: {
    AmazeballsEntry(date: .now)
}

#Preview("Inline", as: .accessoryInline) {
    AmazeballsWatchWidget()
} timeline: {
    AmazeballsEntry(date: .now)
}

#Preview("Corner", as: .accessoryCorner) {
    AmazeballsWatchWidget()
} timeline: {
    AmazeballsEntry(date: .now)
}

