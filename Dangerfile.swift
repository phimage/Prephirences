import Danger
import Foundation


let danger = Danger()

let github = danger.github


// Make it more obvious that a PR is a work in progress and shouldn't be merged yet
if danger.github.pullRequest.title.contains("WIP") {
    warn("PR is classed as Work in Progress")
}

// Warn when there is a big PR
if (danger.github.pullRequest.additions ?? 0) > 500 {
    warn("Big PR, try to keep changes smaller if you can")
}
let allSourceFiles = danger.git.modifiedFiles + danger.git.createdFiles

// SwiftLint
SwiftLint.lint(inline: true, configFile: ".swiftlint.yml")
