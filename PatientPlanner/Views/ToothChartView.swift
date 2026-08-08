import SwiftUI

/// Визуальная зубная формула (одонтограмма) — двухцифровая система FDI,
/// как на образце: 4 квадранта по 8 зубов, для каждого можно выбрать код состояния.
struct ToothChartView: View {
    @Binding var toothFormula: [Int: String]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            quadrantRow(left: ToothChart.upperRight, right: ToothChart.upperLeft)
            Divider()
            quadrantRow(left: ToothChart.lowerLeft, right: ToothChart.lowerRight)
        }
    }

    private func quadrantRow(left: [Int], right: [Int]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(left, id: \.self) { toothCell($0) }
                Rectangle()
                    .frame(width: 1)
                    .foregroundStyle(.secondary.opacity(0.3))
                    .padding(.vertical, 4)
                ForEach(right, id: \.self) { toothCell($0) }
            }
        }
    }

    private func toothCell(_ number: Int) -> some View {
        let status = toothFormula[number] ?? ""
        let isNorm = status.isEmpty || status == ToothStatusCode.norm.rawValue

        return Menu {
            ForEach(ToothStatusCode.allCases) { code in
                Button {
                    toothFormula[number] = code.rawValue
                } label: {
                    Text("\(code.rawValue) — \(code.fullDescription)")
                }
            }
        } label: {
            VStack(spacing: 3) {
                Text(status.isEmpty ? "—" : status)
                    .font(.caption.bold())
                    .foregroundStyle(isNorm ? .secondary : Color.accentColor)
                Text("\(number)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 40, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isNorm ? Color(.secondarySystemBackground) : Color.accentColor.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
