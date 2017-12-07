import SakefileDescription
import SakefileUtils

Sake {
    $0.task(name: "build", description: "xxx", action: { (utils) in
        print("Shakira")
    })
}.run()
