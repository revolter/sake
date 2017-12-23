import Foundation
import xcproj
import PathKit

/// Generates a Xcode Project to edit the Sakefile.
public class GenerateProject {
    
    // MARK: - Attributes
    
    /// Path to the folder where the Sakefile.swift is.
    fileprivate let path: String
    
    /// File manager.
    fileprivate let fileManager: FileManager = .default

    /// Project writer.
    fileprivate let write: (XcodeProj, Path) throws -> Void
    
    /// File description path.
    fileprivate let filedescriptionLibraryPath: () -> Path?
    
    /// Utils library path.
    fileprivate let utilsLibraryPath: () -> Path?
    
    /// Sakefile path.
    fileprivate let sakefilePath: () -> Path?
    
    // MARK: - Init
    
    /// Initializes the command with the path to the folder where the Sakefile.swift is.
    ///
    /// - Parameter path: path to the folder where the Sakefile.swift file is.
    convenience public init(path: String) {
        self.init(path: path,
                  write: { try $0.write(path: $1) },
                  filedescriptionLibraryPath: { Runtime.filedescriptionLibraryPath() },
                  utilsLibraryPath: { Runtime.utilsLibraryPath() },
                  sakefilePath: {
                    let path = Path("Sakefile.swift").absolute()
                    return path.exists ? path : nil
        })
    }
    
    init(path: String,
         write: @escaping (XcodeProj, Path) throws -> Void,
         filedescriptionLibraryPath: @escaping () -> Path?,
         utilsLibraryPath: @escaping () -> Path?,
         sakefilePath: @escaping () -> Path?) {
        self.path = path
        self.write = write
        self.filedescriptionLibraryPath = filedescriptionLibraryPath
        self.utilsLibraryPath = utilsLibraryPath
        self.sakefilePath = sakefilePath
    }
    
    // MARK: - Public
    
    /// Generates the Xcode project.
    ///
    /// - Throws: error if the generation fails.
    public func execute() throws {
        let projectPath = URL.init(fileURLWithPath: path).appendingPathComponent("Sakefile.xcodeproj")
        if fileManager.fileExists(atPath: projectPath.path) {
            try fileManager.removeItem(at: projectPath)
        }
        let workspaceData = XCWorkspace.Data(references: [])
        let workspace = XCWorkspace(data: workspaceData)
        let pbxproj = PBXProj(objectVersion: 48, rootObject: "PROJECT")
        let project = XcodeProj(workspace: workspace, pbxproj: pbxproj)
        let mainSwiftPath = try createMainSwiftIfNeeded()
        try setup(pbxproj: pbxproj, mainSwiftPath: mainSwiftPath)
        try write(project, Path(projectPath.path))
    }
    
    fileprivate func createMainSwiftIfNeeded() throws -> Path {
        let tmpPath = Path(NSTemporaryDirectory())
        let tmpSakePath = tmpPath + "Sake"
        if !tmpSakePath.exists {
            try tmpSakePath.mkpath()
        }
        let mainSwiftPath = tmpSakePath + "main.swift"
        let mainSwiftContent = """
import Foundation

// NOTE: Don't add anything to this file
"""
        if !mainSwiftPath.exists {
            try mainSwiftPath.write(mainSwiftContent)
        }
        return mainSwiftPath
    }
    
    fileprivate func setup(pbxproj: PBXProj,
                           mainSwiftPath: Path) throws {
        guard let sakefilePath = sakefilePath() else {
            throw "Couldn't file a Sakefile.swift file in the current directory"
        }
        guard let filedescriptionLibraryPath = filedescriptionLibraryPath() else {
            throw "Couldn't find libSakefileDescription"
        }
        let utilsLibraryPath = self.utilsLibraryPath()
        addFileReferences(pbxproj: pbxproj,
                          filedescriptionLibraryPath: filedescriptionLibraryPath,
                          utilsLibraryPath: utilsLibraryPath,
                          sakefilePath: sakefilePath,
                          mainSwiftPath: mainSwiftPath)
        addGroups(pbxproj: pbxproj, withUtils: utilsLibraryPath != nil)
        addBuildFiles(pbxproj: pbxproj, withUtils: utilsLibraryPath != nil)
        addBuildPhases(pbxproj: pbxproj, withUtils: utilsLibraryPath != nil)
        addConfigurations(pbxproj: pbxproj, libraryPath: filedescriptionLibraryPath.parent())
        addNativeTargets(pbxproj: pbxproj)
        addProject(pbxproj: pbxproj)
    }
    
    fileprivate func addFileReferences(pbxproj: PBXProj,
                                       filedescriptionLibraryPath: Path,
                                       utilsLibraryPath: Path?,
                                       sakefilePath: Path,
                                       mainSwiftPath: Path) {
        pbxproj.objects.addObject(PBXFileReference(reference: "FILE_REF_PRODUCT",
                                                   sourceTree: .buildProductsDir,
                                                   explicitFileType: "compiled.mach-o.executable",
                                                   path: "Sakefile",
                                                   includeInIndex: 0))
        pbxproj.objects.addObject(PBXFileReference(reference: "FILE_REF_SAKEFILE",
                                                   sourceTree: .absolute,
                                                   name: "Sakefile.swift",
                                                   lastKnownFileType: "sourcecode.swift",
                                                   path: sakefilePath.string))
        pbxproj.objects.addObject(PBXFileReference(reference: "FILE_REF_LIB",
                                                   sourceTree: .absolute,
                                                   name: filedescriptionLibraryPath.lastComponent,
                                                   lastKnownFileType: "compiled.mach-o.dylib",
                                                   path: filedescriptionLibraryPath.string))
        pbxproj.objects.addObject(PBXFileReference(reference: "FILE_REF_MAIN",
                                                   sourceTree: .absolute,
                                                   name: mainSwiftPath.lastComponent,
                                                   lastKnownFileType: "sourcecode.swift",
                                                   path: mainSwiftPath.absolute().string))
        if let utilsLibraryPath = utilsLibraryPath {
            pbxproj.objects.addObject(PBXFileReference(reference: "FILE_REF_LIB_UTILS",
                                                       sourceTree: .absolute,
                                                       name: utilsLibraryPath.lastComponent,
                                                       lastKnownFileType: "compiled.mach-o.dylib",
                                                       path: utilsLibraryPath.string))
        }
    }
    
    fileprivate func addGroups(pbxproj: PBXProj, withUtils: Bool) {
        pbxproj.objects.addObject(PBXGroup(reference: "GROUP_PRODUCTS",
                                           children: ["FILE_REF_PRODUCT"],
                                           sourceTree: .group,
                                           name: "Products"))
        pbxproj.objects.addObject(PBXGroup(reference: "GROUP_MAIN",
                                           children: ["FILE_REF_SAKEFILE", "FILE_REF_MAIN", "GROUP_PRODUCTS", "GROUP_FRAMEWORKS"],
                                           sourceTree: .group))
        var frameworks: [String] = ["FILE_REF_LIB"]
        if withUtils {
            frameworks.append("FILE_REF_LIB_UTILS")
        }
        pbxproj.objects.addObject(PBXGroup(reference: "GROUP_FRAMEWORKS",
                                           children: frameworks,
                                           sourceTree: .group,
                                           name: "Frameworks"))
    }
    
    fileprivate func addBuildFiles(pbxproj: PBXProj, withUtils: Bool) {
        pbxproj.objects.addObject(PBXBuildFile(reference: "BUILD_FILE_SAKEFILE",
                                               fileRef: "FILE_REF_SAKEFILE"))
        pbxproj.objects.addObject(PBXBuildFile(reference: "BUILD_FILE_LIB",
                                               fileRef: "FILE_REF_LIB"))
        pbxproj.objects.addObject(PBXBuildFile(reference: "BUILD_FILE_MAIN",
                                               fileRef: "FILE_REF_MAIN"))
        if withUtils {
            pbxproj.objects.addObject(PBXBuildFile(reference: "BUILD_FILE_LIB_UTILS",
                                                   fileRef: "FILE_REF_LIB_UTILS"))
        }
    }
    
    fileprivate func addBuildPhases(pbxproj: PBXProj, withUtils: Bool) {
        var frameworks: [String] = ["BUILD_FILE_LIB"]
        if withUtils {
            frameworks.append("BUILD_FILE_LIB_UTILS")
        }
        pbxproj.objects.addObject(PBXFrameworksBuildPhase(reference: "FRAMEWORKS_BUILD_PHASE",
                                                          files: frameworks,
                                                          buildActionMask: PBXFrameworksBuildPhase.defaultBuildActionMask,
                                                          runOnlyForDeploymentPostprocessing: 0))
        
        pbxproj.objects.addObject(PBXSourcesBuildPhase(reference: "SOURCE_BUILD_PHASE",
                                                       files: ["BUILD_FILE_SAKEFILE", "BUILD_FILE_MAIN"],
                                                       buildActionMask: PBXSourcesBuildPhase.defaultBuildActionMask,
                                                       runOnlyForDeploymentPostprocessing: 0))
        pbxproj.objects.addObject(PBXCopyFilesBuildPhase(reference: "COPY_FILES_BUILD_PHASE",
                                                         dstPath: "/usr/share/man/man1/",
                                                         dstSubfolderSpec: PBXCopyFilesBuildPhase.SubFolder.absolutePath,
                                                         buildActionMask: PBXCopyFilesBuildPhase.defaultBuildActionMask,
                                                         files: [],
                                                         runOnlyForDeploymentPostprocessing: 1))
    }
    
    fileprivate func addConfigurations(pbxproj: PBXProj, libraryPath: Path) {
        pbxproj.objects.addObject(XCBuildConfiguration(reference: "CONFIGURATION_TARGET",
                                                       name: "Debug",
                                                       baseConfigurationReference: nil,
                                                       buildSettings: [
                                                        "LIBRARY_SEARCH_PATHS": libraryPath.absolute().string,
                                                        "PRODUCT_NAME": "$(TARGET_NAME)",
                                                        "SWIFT_INCLUDE_PATHS": libraryPath.absolute().string,
                                                        "SWIFT_VERSION": "4.0"]))
        pbxproj.objects.addObject(XCBuildConfiguration(reference: "CONFIGURATION_PROJECT",
                                                       name: "Debug",
                                                       baseConfigurationReference: nil,
                                                       buildSettings: [
                                                        "ALWAYS_SEARCH_USER_PATHS": "NO",
                                                        "CLANG_ANALYZER_NONNULL": "YES",
                                                        "CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION": "YES_AGGRESSIVE",
                                                        "CLANG_CXX_LANGUAGE_STANDARD": "gnu++14",
                                                        "CLANG_CXX_LIBRARY": "libc++",
                                                        "CLANG_ENABLE_MODULES": "YES",
                                                        "CLANG_ENABLE_OBJC_ARC": "YES",
                                                        "CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING": "YES",
                                                        "CLANG_WARN_BOOL_CONVERSION": "YES",
                                                        "CLANG_WARN_COMMA": "YES",
                                                        "CLANG_WARN_CONSTANT_CONVERSION": "YES",
                                                        "CLANG_WARN_DIRECT_OBJC_ISA_USAGE": "YES_ERROR",
                                                        "CLANG_WARN_DOCUMENTATION_COMMENTS": "YES",
                                                        "CLANG_WARN_EMPTY_BODY": "YES",
                                                        "CLANG_WARN_ENUM_CONVERSION": "YES",
                                                        "CLANG_WARN_INFINITE_RECURSION": "YES",
                                                        "CLANG_WARN_INT_CONVERSION": "YES",
                                                        "CLANG_WARN_NON_LITERAL_NULL_CONVERSION": "YES",
                                                        "CLANG_WARN_OBJC_LITERAL_CONVERSION": "YES",
                                                        "CLANG_WARN_OBJC_ROOT_CLASS": "YES_ERROR",
                                                        "CLANG_WARN_RANGE_LOOP_ANALYSIS": "YES",
                                                        "CLANG_WARN_STRICT_PROTOTYPES": "YES",
                                                        "CLANG_WARN_SUSPICIOUS_MOVE": "YES",
                                                        "CLANG_WARN_UNGUARDED_AVAILABILITY": "YES_AGGRESSIVE",
                                                        "CLANG_WARN_UNREACHABLE_CODE": "YES",
                                                        "CLANG_WARN__DUPLICATE_METHOD_MATCH": "YES",
                                                        "COPY_PHASE_STRIP": "NO",
                                                        "DEBUG_INFORMATION_FORMAT": "dwarf",
                                                        "ENABLE_STRICT_OBJC_MSGSEND": "YES",
                                                        "ENABLE_TESTABILITY": "YES",
                                                        "GCC_C_LANGUAGE_STANDARD": "gnu11",
                                                        "GCC_DYNAMIC_NO_PIC": "NO",
                                                        "GCC_NO_COMMON_BLOCKS": "YES",
                                                        "GCC_OPTIMIZATION_LEVEL": "0",
                                                        "GCC_PREPROCESSOR_DEFINITIONS": "DEBUG=1 $(inherited)",
                                                        "GCC_WARN_64_TO_32_BIT_CONVERSION": "YES",
                                                        "GCC_WARN_ABOUT_RETURN_TYPE": "YES_ERROR",
                                                        "GCC_WARN_UNDECLARED_SELECTOR": "YES",
                                                        "GCC_WARN_UNINITIALIZED_AUTOS": "YES_AGGRESSIVE",
                                                        "GCC_WARN_UNUSED_FUNCTION": "YES",
                                                        "GCC_WARN_UNUSED_VARIABLE": "YES",
                                                        "LD_DYLIB_INSTALL_NAME": "@rpath",
                                                        "MACOSX_DEPLOYMENT_TARGET": "10.10",
                                                        "MTL_ENABLE_DEBUG_INFO": "YES",
                                                        "ONLY_ACTIVE_ARCH": "YES",
                                                        "SDKROOT": "macosx",
                                                        "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
                                                        "USE_HEADERMAP": "NO"]))
        pbxproj.objects.addObject(XCConfigurationList(reference: "CONFIGURATION_LIST_PROJECT",
                                                      buildConfigurations: ["CONFIGURATION_PROJECT"],
                                                      defaultConfigurationName: "Debug",
                                                      defaultConfigurationIsVisible: 0))
        pbxproj.objects.addObject(XCConfigurationList(reference: "CONFIGURATION_LIST_TARGET",
                                                      buildConfigurations: ["CONFIGURATION_TARGET"],
                                                      defaultConfigurationName: "Debug",
                                                      defaultConfigurationIsVisible: 0))
    }
    
    fileprivate func addNativeTargets(pbxproj: PBXProj) {
        pbxproj.objects.addObject(PBXNativeTarget(reference: "NATIVE_TARGET",
                                                  name: "Sakefile",
                                                  buildConfigurationList: "CONFIGURATION_LIST_TARGET",
                                                  buildPhases: ["SOURCE_BUILD_PHASE", "FRAMEWORKS_BUILD_PHASE", "COPY_FILES_BUILD_PHASE"],
                                                  buildRules: [],
                                                  dependencies: [],
                                                  productName: "Sakefile",
                                                  productReference: "FILE_REF_PRODUCT",
                                                  productType: .commandLineTool))
    }
    
    fileprivate func addProject(pbxproj: PBXProj) {
        pbxproj.objects.addObject(PBXProject(name: "Sakefile",
                                             reference: "PROJECT",
                                             buildConfigurationList: "CONFIGURATION_LIST_PROJECT",
                                             compatibilityVersion: "Xcode 8.0",
                                             mainGroup: "GROUP_MAIN",
                                             developmentRegion: "en",
                                             hasScannedForEncodings: 0,
                                             knownRegions: ["en"],
                                             productRefGroup: "GROUP_PRODUCTS",
                                             projectDirPath: "",
                                             projectReferences: [],
                                             projectRoot: "",
                                             targets: ["NATIVE_TARGET"],
                                             attributes: ["ORGANIZATIONNAME": "com.sake"]))
    }
}
