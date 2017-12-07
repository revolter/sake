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
    
    // MARK: - Init
    
    /// Initializes the command with the path to the folder where the Sakefile.swift is.
    ///
    /// - Parameter path: path to the folder where the Sakefile.swift file is.
    public init(path: String) {
        self.path = path
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
        try setup(pbxproj: pbxproj)
        try project.write(path: Path(projectPath.path))
    }

    fileprivate func setup(pbxproj: PBXProj) throws {
        let sakefilePath = Path("Sakefile.swift").absolute()
        if !sakefilePath.exists {
            throw "Couldn't file a Sakefile.swift file in the current directory"
        }
        
        // File references
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
        guard let libraryPath = Runtime.libraryFolder() else {
            throw "Couldn't find libSakefileDescription"
        }
        addFileReferences(pbxproj: pbxproj, libraryPath: libraryPath)
        addGroups(pbxproj: pbxproj)
        addBuildFiles(pbxproj: pbxproj)
        addBuildPhases(pbxproj: pbxproj)
        addConfigurations(pbxproj: pbxproj, libraryPath: libraryPath)
        addNativeTargets(pbxproj: pbxproj)
        addProject(pbxproj: pbxproj)
    }
    
    fileprivate func addFileReferences(pbxproj: PBXProj, libraryPath: Path) {
        let dylibPath = (libraryPath + "libSakefileDescription.dylib").absolute()
        pbxproj.objects.addObject(PBXFileReference(reference: "FILE_REF_LIB",
                                                   sourceTree: .absolute,
                                                   name: "libSakefileDescription.dylib",
                                                   lastKnownFileType: "compiled.mach-o.dylib",
                                                   path: dylibPath.string))
    }
    
    fileprivate func addGroups(pbxproj: PBXProj) {
        pbxproj.objects.addObject(PBXGroup(reference: "GROUP_PRODUCTS",
                                           children: ["FILE_REF_PRODUCT"],
                                           sourceTree: .group,
                                           name: "Products"))
        pbxproj.objects.addObject(PBXGroup(reference: "GROUP_FRAMEWORKS",
                                           children: ["FILE_REF_LIB"],
                                           sourceTree: .group,
                                           name: "Frameworks"))
        
        pbxproj.objects.addObject(PBXGroup(reference: "GROUP_MAIN",
                                           children: ["FILE_REF_SAKEFILE", "GROUP_PRODUCTS", "GROUP_FRAMEWORKS"],
                                           sourceTree: .group))
    }
    
    fileprivate func addBuildFiles(pbxproj: PBXProj) {
        pbxproj.objects.addObject(PBXBuildFile(reference: "BUILD_FILE_SAKEFILE",
                                               fileRef: "FILE_REF_SAKEFILE"))
        pbxproj.objects.addObject(PBXBuildFile(reference: "BUILD_FILE_LIB",
                                               fileRef: "FILE_REF_LIB"))
    }
    
    fileprivate func addBuildPhases(pbxproj: PBXProj) {
        pbxproj.objects.addObject(PBXFrameworksBuildPhase(reference: "FRAMEWORKS_BUILD_PHASE",
                                                          files: ["BUILD_FILE_LIB"],
                                                          buildActionMask: PBXFrameworksBuildPhase.defaultBuildActionMask,
                                                          runOnlyForDeploymentPostprocessing: 0))
        pbxproj.objects.addObject(PBXSourcesBuildPhase(reference: "SOURCE_BUILD_PHASE",
                                                       files: ["BUILD_FILE_SAKEFILE"],
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
