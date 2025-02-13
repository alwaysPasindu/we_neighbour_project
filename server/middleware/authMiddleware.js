const jwt = require('jsonwebtoken');

exports.authenticate = function(req, res, next){
    const token = req.header('x-auth-token');
    if(!token) return res.status(401).json({message:"No token, authorization failed"});

    try{
        const decoded = jwt.verify(token, process.env.JWT_SCECRET);
        req.user = decoded;

        next();

    }catch(err){
        res.status(401).json({message:"Token is not valid"});
    }
};

exports.isResident = function(req, res, next){
    if(req.user.role != 'Resident'){
        return res.status(403).json({message:"Access denied. Not authorized as a Resident."});
    }
    next();
};

exports.isManager = function(req,res,next){
    if(req.user.role != 'Manager'){
        return res.status(403).json({message:"Access denied. Not authorized as a Service Provider."});
    }
    next();
};

exports.isServiceProvider = function(req,res,next){
    if(req.user.role != 'ServiceProvider'){
        return res.status(403).json({message:"Access denied. Not authorized as a Service Provider."});
    }
    next();
};

